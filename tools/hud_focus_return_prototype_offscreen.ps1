# hud_focus_return_prototype_offscreen.ps1
# Purpose:
#   Minimal prototype:
#   - Keep a small HUD window running and visible to the taskbar.
#   - Pin it to taskbar and call it with Win+number.
#   - When HUD is focused, press any key.
#   - On key release, HUD is moved offscreen / sent behind instead of minimized.
#   - Focus returns to the previous external window.
#
# Run:
#   powershell -NoProfile -ExecutionPolicy Bypass -File .\hud_focus_return_prototype_offscreen.ps1

Add-Type -ReferencedAssemblies System.Windows.Forms,System.Drawing -TypeDefinition @"
using System;
using System.Drawing;
using System.Runtime.InteropServices;
using System.Windows.Forms;

public static class HudFocusReturnPrototype
{
    [DllImport("user32.dll")]
    private static extern IntPtr GetForegroundWindow();

    [DllImport("user32.dll")]
    private static extern bool SetForegroundWindow(IntPtr hWnd);

    [DllImport("user32.dll")]
    private static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

    [DllImport("user32.dll")]
    private static extern bool IsWindow(IntPtr hWnd);

    [DllImport("user32.dll")]
    private static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint processId);

    [DllImport("user32.dll", SetLastError = true)]
    private static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);

    private static readonly IntPtr HWND_BOTTOM = new IntPtr(1);
    private static readonly IntPtr HWND_TOPMOST = new IntPtr(-1);

    private const int SW_RESTORE = 9;
    private const uint SWP_NOSIZE = 0x0001;
    private const uint SWP_NOACTIVATE = 0x0010;
    private const uint SWP_SHOWWINDOW = 0x0040;

    private static IntPtr lastExternalWindow = IntPtr.Zero;
    private static HudForm form;

    public static void Run()
    {
        Application.EnableVisualStyles();
        Application.SetCompatibleTextRenderingDefault(false);

        form = new HudForm();
        Application.Run(form);
    }

    private static bool IsOurProcessWindow(IntPtr hWnd)
    {
        if (hWnd == IntPtr.Zero) return false;

        uint targetProcessId;
        GetWindowThreadProcessId(hWnd, out targetProcessId);

        uint currentProcessId = (uint)System.Diagnostics.Process.GetCurrentProcess().Id;
        return targetProcessId == currentProcessId;
    }

    private static void TrackForegroundWindow()
    {
        IntPtr current = GetForegroundWindow();

        if (current == IntPtr.Zero) return;
        if (!IsWindow(current)) return;

        // Avoid remembering this HUD or the PowerShell console that hosts it.
        if (IsOurProcessWindow(current)) return;

        lastExternalWindow = current;
    }

    private static void ReturnToPreviousWindow()
    {
        IntPtr target = lastExternalWindow;

        // Avoid minimize animation. Keep the window alive for Win+number,
        // but move it offscreen and send it behind other windows.
        if (form != null && !form.IsDisposed)
        {
            form.TopMost = false;
            int offX = SystemInformation.VirtualScreen.Left - form.Width - 80;
            int offY = SystemInformation.VirtualScreen.Top - form.Height - 80;
            SetWindowPos(form.Handle, HWND_BOTTOM, offX, offY, 0, 0, SWP_NOSIZE | SWP_NOACTIVATE | SWP_SHOWWINDOW);
        }

        if (target != IntPtr.Zero && IsWindow(target))
        {
            ShowWindow(target, SW_RESTORE);
            SetForegroundWindow(target);
        }
    }

    private sealed class HudForm : Form
    {
        private readonly Label title;
        private readonly Label body;
        private readonly Timer tracker;
        private bool waitingForKeyUp = false;
        private Keys pressedKey = Keys.None;

        public HudForm()
        {
            this.Text = "HUD Focus Return Prototype";
            this.StartPosition = FormStartPosition.CenterScreen;
            this.Size = new Size(460, 220);
            this.MinimumSize = new Size(460, 220);
            this.TopMost = true;
            this.KeyPreview = true;
            this.ShowInTaskbar = true;
            this.BackColor = Color.FromArgb(28, 28, 28);
            this.ForeColor = Color.White;

            title = new Label();
            title.AutoSize = false;
            title.Dock = DockStyle.Top;
            title.Height = 54;
            title.TextAlign = ContentAlignment.MiddleCenter;
            title.Font = new Font("Segoe UI", 16, FontStyle.Bold);
            title.Text = "HUD Prototype";

            body = new Label();
            body.AutoSize = false;
            body.Dock = DockStyle.Fill;
            body.TextAlign = ContentAlignment.MiddleCenter;
            body.Font = new Font("Segoe UI", 11, FontStyle.Regular);
            body.Text =
                "Pin this window to the taskbar and call it with Win+number.\n\n" +
                "When this window is focused:\n" +
                "1. Press any key\n" +
                "2. Release the key\n" +
                "3. This window moves offscreen and focus returns";

            this.Controls.Add(body);
            this.Controls.Add(title);

            tracker = new Timer();
            tracker.Interval = 100;
            tracker.Tick += delegate { TrackForegroundWindow(); };
            tracker.Start();

            this.Activated += delegate
            {
                // Win+number should make the HUD visible again.
                this.WindowState = FormWindowState.Normal;
                this.Size = new Size(460, 220);
                this.Location = new Point(
                    SystemInformation.WorkingArea.Left + (SystemInformation.WorkingArea.Width - this.Width) / 2,
                    SystemInformation.WorkingArea.Top + (SystemInformation.WorkingArea.Height - this.Height) / 2
                );
                this.TopMost = true;
                SetWindowPos(this.Handle, HWND_TOPMOST, this.Left, this.Top, 0, 0, SWP_NOSIZE | SWP_SHOWWINDOW);

                waitingForKeyUp = false;
                pressedKey = Keys.None;
                title.Text = "HUD Prototype";
                body.Text =
                    "Focused.\n\n" +
                    "Press any key, then release it.\n" +
                    "On key release, focus returns without minimize animation.";
            };

            this.KeyDown += OnKeyDown;
            this.KeyUp += OnKeyUp;
            this.FormClosing += delegate { tracker.Stop(); };
        }

        private void OnKeyDown(object sender, KeyEventArgs e)
        {
            if (!waitingForKeyUp)
            {
                waitingForKeyUp = true;
                pressedKey = e.KeyCode;
                title.Text = "Key Down";
                body.Text =
                    "Pressed: " + pressedKey.ToString() + "\n\n" +
                    "Release this key to return to the previous window.";
            }

            e.Handled = true;
            e.SuppressKeyPress = true;
        }

        private void OnKeyUp(object sender, KeyEventArgs e)
        {
            if (waitingForKeyUp && e.KeyCode == pressedKey)
            {
                waitingForKeyUp = false;
                Keys released = pressedKey;
                pressedKey = Keys.None;

                title.Text = "Returning";
                body.Text = "Released: " + released.ToString() + "\nReturning focus...";

                Timer once = new Timer();
                once.Interval = 30;
                once.Tick += delegate
                {
                    once.Stop();
                    once.Dispose();
                    ReturnToPreviousWindow();
                };
                once.Start();
            }

            e.Handled = true;
            e.SuppressKeyPress = true;
        }
    }
}
"@

[HudFocusReturnPrototype]::Run()
