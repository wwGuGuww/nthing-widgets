param([string]$cmd = 'get')
# Prints the master volume (0-100, or 0 when muted). up / down change it by 2 %, mute toggles mute.
Add-Type -TypeDefinition @'
using System; using System.Runtime.InteropServices;
[Guid("5CDF2C82-841E-4546-9722-0CF74078229A"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IAudioEndpointVolume {
  int a(); int b(); int c(); int d();
  int SetMasterVolumeLevelScalar(float l, Guid ctx);
  int f();
  int GetMasterVolumeLevelScalar(out float l);
  int g(); int h(); int i(); int j();
  int SetMute([MarshalAs(UnmanagedType.Bool)] bool m, Guid ctx);
  int GetMute([MarshalAs(UnmanagedType.Bool)] out bool m);
}
[Guid("D666063F-1587-4E43-81F1-B948E807363F"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IMMDevice { int Activate(ref Guid id, int ctx, IntPtr p, out IAudioEndpointVolume v); }
[Guid("A95664D2-9614-4F35-A746-DE8DB63617E6"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IMMDeviceEnumerator { int f(); int GetDefaultAudioEndpoint(int flow, int role, out IMMDevice d); }
[ComImport, Guid("BCDE0395-E52F-467C-8E3D-C4579291692E")] class MMDeviceEnumeratorComObject { }
public class NThingAudio {
  static IAudioEndpointVolume Ep() {
    var e = new MMDeviceEnumeratorComObject() as IMMDeviceEnumerator; IMMDevice d;
    e.GetDefaultAudioEndpoint(0, 1, out d);
    var g = typeof(IAudioEndpointVolume).GUID; IAudioEndpointVolume v;
    d.Activate(ref g, 23, IntPtr.Zero, out v); return v;
  }
  public static int Run(string cmd) {
    var v = Ep(); float l; bool m;
    v.GetMasterVolumeLevelScalar(out l); v.GetMute(out m);
    if (cmd == "up")   { l = Math.Min(1f, l + 0.02f); v.SetMasterVolumeLevelScalar(l, Guid.Empty); }
    if (cmd == "down") { l = Math.Max(0f, l - 0.02f); v.SetMasterVolumeLevelScalar(l, Guid.Empty); }
    if (cmd == "mute") { m = !m; v.SetMute(m, Guid.Empty); }
    return m ? 0 : (int)Math.Round(l * 100);
  }
}
'@
[Console]::Out.Write([NThingAudio]::Run($cmd))
