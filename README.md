# rustdesk-setup

Sets up RustDesk to use the Fixetics self-hosted server (`rustdesk.fixetics.co.za`).

## Option 1: script (any PC, installs or fixes an existing install)

Open PowerShell **as Administrator** and paste:

```powershell
irm https://raw.githubusercontent.com/iEdgir01/rustdesk-setup/main/setup.ps1 | iex
```

It installs the latest RustDesk if missing, applies the server settings, and prints the PC's ID.

## Option 2: pre-configured installer

Download the `.exe` from the [latest release](https://github.com/iEdgir01/rustdesk-setup/releases/latest) and run it.
The server settings are encoded in the filename, so don't rename it.
