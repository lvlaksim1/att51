// Standalone Windows Forms updater. No PowerShell; built against .NET Framework.
// The main program copies this EXE to {app}\updates before running it.
using System;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Net;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Windows.Forms;

internal sealed class UpdateWindow : Form {
    readonly string tag, hash, root, updates, ready, installProgress, newAppReady;
    readonly long size;
    readonly int oldPid;
    readonly Label caption;
    readonly ProgressBar bar;
    readonly string installer, partial;
    volatile bool busy = true;

    internal UpdateWindow(string[] a) {
        long parsedSize;
        int parsedPid;
        if (a.Length != 5 || !Regex.IsMatch(a[0], @"^v(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$")
            || !Regex.IsMatch(a[1], @"^[a-fA-F0-9]{64}$")
            || !long.TryParse(a[2], out parsedSize) || parsedSize < 100000
            || !int.TryParse(a[3], out parsedPid) || parsedPid <= 0)
            throw new InvalidOperationException("Недопустимые параметры обновления.");
        size = parsedSize;
        oldPid = parsedPid;
        tag = a[0];
        hash = a[1].ToLowerInvariant();
        root = Path.GetFullPath(a[4]).TrimEnd(Path.DirectorySeparatorChar);
        if (!String.Equals(Path.GetFileName(root), "Att51_export", StringComparison.OrdinalIgnoreCase))
            throw new InvalidOperationException("Недопустимая папка приложения.");
        updates = Path.Combine(root, "updates");
        ready = Path.Combine(updates, "overlay.ready");
        installProgress = Path.Combine(updates, "install.progress");
        newAppReady = Path.Combine(updates, "newapp.ready");
        installer = Path.Combine(updates, "Att51_export_Update_" + tag + ".exe");
        partial = installer + ".download";
        Text = "Обновление Att51_export";
        StartPosition = FormStartPosition.CenterScreen;
        Size = new Size(490, 158);
        FormBorderStyle = FormBorderStyle.FixedDialog;
        ControlBox = false;
        TopMost = true;
        Font = new Font("Segoe UI", 10f);
        caption = new Label() { Left = 18, Top = 14, Width = 445, Height = 49,
                                 Text = "Подготовка обновления…" };
        bar = new ProgressBar() { Left = 18, Top = 80, Width = 442, Height = 22,
                                  Minimum = 0, Maximum = 100 };
        Controls.Add(caption);
        Controls.Add(bar);
        Shown += delegate {
            try {
                Directory.CreateDirectory(updates);
                File.WriteAllText(ready, "VISIBLE", Encoding.ASCII);
                Thread t = new Thread(Execute);
                t.IsBackground = true;
                t.Start();
            } catch (Exception e) { Failed(e); }
        };
        FormClosing += delegate(object sender, FormClosingEventArgs e) {
            if (busy && e.CloseReason == CloseReason.UserClosing) e.Cancel = true;
        };
    }

    void Progress(int value, string message) {
        if (IsDisposed || !IsHandleCreated) return;
        try {
            BeginInvoke(new Action(delegate {
                bar.Value = Math.Max(0, Math.Min(100, value));
                caption.Text = message;
            }));
        } catch (InvalidOperationException) { }
    }

    void Failed(Exception exc) {
        Action report = delegate {
            busy = false;
            MessageBox.Show(this, "Ошибка обновления: " + exc.Message,
                            "Att51_export", MessageBoxButtons.OK, MessageBoxIcon.Error);
            Close();
        };
        if (InvokeRequired) BeginInvoke(report); else report();
    }

    static void RemoveIfPresent(string path) {
        if (File.Exists(path)) File.Delete(path);
    }

    void Download() {
        string url = "https://github.com/lvlaksim1/att51/releases/download/" +
                     tag + "/" + Path.GetFileName(installer);
        ServicePointManager.SecurityProtocol = (SecurityProtocolType)3072; // TLS 1.2
        HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url);
        request.UserAgent = "Att51_export/Updater";
        request.Timeout = 30000;
        request.ReadWriteTimeout = 90000;
        request.AllowAutoRedirect = true;
        long received = 0;
        using (HttpWebResponse response = (HttpWebResponse)request.GetResponse()) {
            Uri actual = response.ResponseUri;
            string host = actual.Host.ToLowerInvariant();
            if (actual.Scheme != Uri.UriSchemeHttps ||
               (host != "github.com" && host != "release-assets.githubusercontent.com"
                    && host != "objects.githubusercontent.com"))
                throw new InvalidOperationException("Недоверенный адрес загрузки.");
            using (Stream input = response.GetResponseStream())
            using (FileStream output = new FileStream(partial, FileMode.CreateNew, FileAccess.Write)) {
                byte[] buffer = new byte[131072];
                int count;
                while ((count = input.Read(buffer, 0, buffer.Length)) > 0) {
                    received += count;
                    if (received > size)
                        throw new InvalidOperationException("Превышен ожидаемый размер обновления.");
                    output.Write(buffer, 0, count);
                    Progress((int)(received * 50L / size),
                             "Загрузка: " + (received * 100L / size) + " %");
                }
            }
        }
        if (received != size)
            throw new InvalidOperationException("Неверный размер загруженного файла.");
        Progress(50, "Проверка контрольной суммы SHA-256…");
        string digest;
        using (SHA256 algorithm = SHA256.Create())
        using (FileStream input = File.OpenRead(partial))
            digest = BitConverter.ToString(algorithm.ComputeHash(input)).Replace("-", "").ToLowerInvariant();
        if (!String.Equals(digest, hash, StringComparison.Ordinal))
            throw new InvalidOperationException("SHA-256 установщика не совпадает.");
        using (FileStream input = File.OpenRead(partial))
            if (input.ReadByte() != 77 || input.ReadByte() != 90)
                throw new InvalidOperationException("Загруженный файл не является EXE.");
        RemoveIfPresent(installer);
        File.Move(partial, installer);
    }

    void WaitForOldApp() {
        Progress(50, "Ожидание завершения предыдущей версии…");
        try {
            using (Process previous = Process.GetProcessById(oldPid))
                if (!previous.WaitForExit(60000))
                    throw new InvalidOperationException("Предыдущая версия не закрылась за 60 секунд.");
        } catch (ArgumentException) { /* Already exited. */ }
    }

    void Install() {
        Progress(52, "Установка обновления…");
        ProcessStartInfo info = new ProcessStartInfo(installer);
        info.WorkingDirectory = updates;
        info.UseShellExecute = false;
        info.CreateNoWindow = true;
        info.Arguments = "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /NOCANCEL " +
                         "/CLOSEAPPLICATIONS /RUNAFTERUPDATE=0 /PROGRESSFILE=\"" +
                         installProgress + "\"";
        using (Process setup = Process.Start(info)) {
            if (setup == null) throw new InvalidOperationException("Не удалось запустить установщик.");
            while (!setup.WaitForExit(160)) {
                try {
                    string[] pair = File.ReadAllText(installProgress).Trim().Split('/');
                    long done, total;
                    if (pair.Length == 2 && long.TryParse(pair[0], out done)
                        && long.TryParse(pair[1], out total) && total > 0)
                        Progress(52 + (int)(42 * Math.Min(done, total) / total),
                                 "Установка обновления…");
                } catch (IOException) { /* Installer may be writing progress now. */ }
            }
            if (setup.ExitCode != 0)
                throw new InvalidOperationException("Установщик завершился с кодом " + setup.ExitCode);
        }
    }

    void Restart() {
        Progress(95, "Запуск обновлённой программы…");
        string exe = Path.Combine(root, "Att51_export.exe");
        if (!File.Exists(exe))
            throw new InvalidOperationException("Не найдено обновлённое приложение.");
        ProcessStartInfo info = new ProcessStartInfo(exe, "--update-started");
        info.WorkingDirectory = root;
        info.UseShellExecute = false;
        using (Process newApp = Process.Start(info)) {
            if (newApp == null)
                throw new InvalidOperationException("Не удалось запустить приложение.");
            for (int i = 0; i < 200; i++) {
                if (File.Exists(newAppReady)) {
                    Progress(100, "Обновление завершено");
                    return;
                }
                if (newApp.HasExited)
                    throw new InvalidOperationException("Новая версия завершилась до готовности.");
                Thread.Sleep(125);
            }
        }
        throw new InvalidOperationException("Программа не подтвердила запуск за 25 секунд.");
    }

    void Execute() {
        try {
            RemoveIfPresent(installProgress);
            RemoveIfPresent(newAppReady);
            RemoveIfPresent(partial);
            Progress(0, "Загрузка обновления…");
            Download();
            WaitForOldApp();
            Install();
            Restart();
            Thread.Sleep(300);
            BeginInvoke(new Action(delegate { busy = false; Close(); }));
        } catch (Exception e) { Failed(e); }
        finally {
            try { RemoveIfPresent(partial); } catch (IOException) { }
        }
    }

    [STAThread]
    static int Main(string[] args) {
        if (args.Length == 1 && args[0] == "--self-test") {
            try {
                using (SHA256 h = SHA256.Create())
                    return h.ComputeHash(Encoding.ASCII.GetBytes("Att51")).Length == 32 ? 0 : 8;
            } catch { return 8; }
        }
        try {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            using (UpdateWindow w = new UpdateWindow(args)) Application.Run(w);
            return 0;
        } catch (Exception e) {
            MessageBox.Show("Не удалось начать обновление: " + e.Message,
                            "Att51_export", MessageBoxButtons.OK, MessageBoxIcon.Error);
            return 1;
        }
    }
}
