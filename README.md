# About the platform

This software is an integrated [cloud computing](https://en.wikipedia.org/wiki/Cloud_computing) service, with applications for both hosting on a **server** (with or without a graphical interface) and for access on a **client**, in a dynamic and synchronized manner.

Notably, its main capabilities include:

- Synchronization of a disk with the network;
- List of files and directories on the disk;
- Obtaining and removing these files and directories;
- Adding or creating new files and directories to the disk.

<p align="center">
  <img src="app/assets/icons/minimal.png" width="250">
</p>

## Operation requirements

To work with this software on your operating system, it is necessary to install the [Flutter](https://flutter.dev) framework on your machine, which also includes the binaries of the [Dart](https://dart.dev) language.

Make sure these platforms are added to your `$PATH` variable in your shell and that all Flutter dependencies are configured using the following command:

```shell
flutter doctor
```

Additionally, it is recommended to use the [Visual Studio Code](https://code.visualstudio.com) development environment with the official Dart and Flutter extensions for debugging and building the platform.

## Necessary configurations

When accessing the platform for the first time, the user will be prompted to send a configuration file in [JSON](https://en.wikipedia.org/wiki/JSON) format, which must be saved with the name **settings.pcc** (*Projetus Cloud Configuration File*), and whose parameters must be filled in according to the model below:

```json
{
  "githubToken": "<Your GitHub access token for dealing with Gists>",
  "databaseGistId": "<Your GitHub Gist ID that will work as a database>",
  "databaseName": "<Your GithHub Gist file name that will store the data>",
  "ipSecretKey": "<An AES cryptography key with 32 characters of length>",
  "ipSecretIv": "<An AES cryptography vector with 16 characters of length>",
  "serverToken": "<A cryptography key for controlling server requests>"
}
```

To this file, one more field, `storagePath`, can be added, which should contain the absolute path of the disk that will be synchronized with the network if the program is run in [headless mode](#headless-mode).

## Compilation and distribution

To build the program as a whole, open the [app](app) folder of the source code of this project in your terminal and initiate it with the following sequence of commands:

```shell
flutter pub get
flutter create . --platforms linux,macos,windows
```

Furthermore, it is recommended to set the application name with the following command:

```shell
dart run rename setAppName --targets linux,macos,windows --value "Projetus.cloud"
```

Similarly, it is recommended to set the application icons with:

```shell
dart run flutter_launcher_icons
```

Considering all these factors, it is possible to build the application with this command:

```shell
flutter build
```

## Specific considerations

### MacOS

If you are working on macOS, make sure that internet access through the application is enabled in your settings. As described in [this article](https://docs.flutter.dev/platform-integration/macos/building#setting-up-entitlements), you can do this by displaying the [app/macos](app/macos) folder in [.vscode/settings.json](.vscode/settings.json) and editing the following files:

- [app/macos/Runner/DebugProfile.entitlements](app/macos/Runner/DebugProfile.entitlements)
- [app/macos/Runner/Release.entitlements](app/macos/Runner/Release.entitlements)

in both of which the following guidelines should be present:

```xml
<key>com.apple.security.network.app-sandbox</key>
<true/>
<key>com.apple.security.network.server</key>
<true/>
<key>com.apple.security.network.client</key>
<true/>
<key>com.apple.security.files.user-selected.read-write</key>
<true/>
<key>com.apple.security.files.downloads.read-write</key>
<true/>
<key>com.apple.security.files.pictures.read-write</key>
<true/>
<key>com.apple.security.files.movies.read-write</key>
<true/>
<key>com.apple.security.files.music.read-write</key>
<true/>
```

### Windows

If you want to create a complete setup for Windows, install the tool [Inno Setup](https://jrsoftware.org/isinfo.php) on your computer, and run a script following the following model, in which simply replace the `ProjectRoot` pre-definition:

```iss
#define ProjectRoot "<Your project root absolute path>"

#define AppName "Projetus.cloud"
#define AppExeName "app.exe"
#define AppVersion "1.0"

#define AppPublisher "Ruan Carllo Silva"
#define AppURL "https://github.com/ruancarllo"

#define AppAssocName "Projetus Cloud Configuration File"
#define AppAssocExt ".pcc"
#define AppAssocKey StringChange(AppAssocName, " ", "") + AppAssocExt

[Setup]
AppId={{B5FD2B1B-4C90-4FEC-BE2F-31345386C38B}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL={#AppURL}
AppSupportURL={#AppURL}
AppUpdatesURL={#AppURL}
DefaultDirName={autopf}\ProjetusCloud
DisableDirPage=yes
ChangesAssociations=yes
DisableProgramGroupPage=yes
LicenseFile={#ProjectRoot}\LICENSE.md
PrivilegesRequired=lowest
OutputDir={#ProjectRoot}
OutputBaseFilename=mysetup
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#ProjectRoot}\app\build\windows\runner\Release\{#AppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#ProjectRoot}\app\build\windows\runner\Release\flutter_windows.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#ProjectRoot}\app\build\windows\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

[Registry]
Root: HKA; Subkey: "Software\Classes\{#AppAssocExt}\OpenWithProgids"; ValueType: string; ValueName: "{#AppAssocKey}"; ValueData: ""; Flags: uninsdeletevalue
Root: HKA; Subkey: "Software\Classes\{#AppAssocKey}"; ValueType: string; ValueName: ""; ValueData: "{#AppAssocName}"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\{#AppAssocKey}\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\{#AppExeName},0"
Root: HKA; Subkey: "Software\Classes\{#AppAssocKey}\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\{#AppExeName}"" ""%1"""
Root: HKA; Subkey: "Software\Classes\Applications\{#AppExeName}\SupportedTypes"; ValueType: string; ValueName: ".myp"; ValueData: ""

[Icons]
Name: "{autoprograms}\{#AppName}"; Filename: "{app}\{#AppExeName}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#AppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(AppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent
```

## Headless mode

Due to compatibility issues with simple or legacy systems that do not support Flutter's graphical interface applications, this software also provides a headless mode, based on [command-line interface](https://en.wikipedia.org/wiki/Command-line_interface), specifically for the **server** case.

This setup can be configured by opening the [app](app) folder in the source code, removing all Flutter-related dependencies from the [app/pubspec.yaml](app/pubspec.yaml) file, and then running the command:

```shell
dart pub get
```

and compiled into a standalone executable with:

```shell
dart compile exe lib/tasks/headless.dart -o "projetus-cloud"
```

To start the execution of this mode, place the **settings.pcc** file in the same folder as the binary generated in the compilation, and open it with two clicks (on Windows systems) or with the following sequence of commands (on Unix systems):

```shell
chmod +x projetus-cloud
./projetus-cloud
```

## Network complications

The use of this platform on the server layer follows a very important precept: exposing the [IP](https://en.wikipedia.org/wiki/Internet_Protocol) of your computer to the internet, as well as [port](https://en.wikipedia.org/wiki/Port_(computer_networking)) 3434 (defined as default), allowing connections with [TCP](https://en.wikipedia.org/wiki/Transmission_Control_Protocol) and [UDP](https://en.wikipedia.org/wiki/User_Datagram_Protocol) protocols. This must be done by configuring the router to which this machine connects, a process that varies according to each carrier.

## Application showcase

<p align="center">
  <img src="app/assets/views/main.png">
</p>

## Project licensing

The source code of this project is licensed under the terms of the [BSD 3-clause Clear license](LICENSE.md), which is simple and permissive.