# Higher.TestPackage

A C# project to test Klondike with Paket as NuGet cache/partial mirror.

It is used to cache some public nuget packages from https://nuget.org/api/v2 to local klondike server and then use that local Klondike with Paket to install those nuget packages.

## Usage

### No cheating
It does not work with Paket 5.84.0 (other versions not tested).
```
$ ide -- -c "cd /ide/work && mono .paket/paket.exe --verbose update"
Paket version 5.84.0
found: /ide/work/paket.dependencies
Parsing /ide/work/paket.dependencies
Resolving packages for group Build:
Resolving packages for group Main:
   0 packages in resolution.
   2 requirements left
     - Dummy.TestPackage, 0.1.331 (from /ide/work/paket.dependencies)
     - gelf4net,  (from /ide/work/paket.dependencies)

  Trying to resolve Dummy.TestPackage 0.1.331 (from /ide/work/paket.dependencies)
 - Dummy.TestPackage is pinned to 0.1.331
Starting request to 'http://klondike-itest:8080/api/odata/FindPackagesById()?semVerLevel=2.0.0&id='Dummy.TestPackage''
Starting request to 'http://klondike-itest:8080/api/odata/FindPackagesById()?semVerLevel=2.0.0&id='gelf4net''
Starting request to 'http://klondike-itest:8080/api/odata/Packages?$filter=(tolower(Id) eq 'dummy.testpackage') and (NormalizedVersion eq '0.1.331')'
```
it hangs.

It helps to use `--no-daemon` option to run Klondike. But in none of the cases
 I tried, Klondike mirrored/cached any packages, after `paket install` or
 `paket update` was run.

### With cheating
1. Use such a `paket.dependencies` file which uses only public nuget sources and
 only public packages:
```
source https://nuget.org/api/v2

nuget System.Collections
```
2. Run
```
ide -- -c "cd /ide/work && mono .paket/paket.exe --verbose update"
```
3. Push all the public packages into Klondike server (as if Klondike worked as
   mirror with Paket). (You can repush many times).
```
ide --idefile Idefile.dotnetcore
cd /ide/work
packages=$(ls packages/**/*.nupkg)
for pkg in $packages; do
  echo "Pushing ${pkg}"
  dotnet nuget push ${pkg}  --source http://klondike-itest:8080/api/odata
done
```
4. Now you can use Klondike as mirror. Use such a `paket.dependencies` file:
```
source http://klondike-itest:8080/api/odata

nuget System.Collections
```
```
ide # use the mono Idefile
time mono .paket/paket.exe --verbose update
# it takes <4 seconds and output contains lines like:
# Starting request to 'http://klondike-itest:8080/api/odata/FindPackagesById()?semVerLevel=2.0.0&id='Microsoft.NETCore.Platforms''
```
5. If you want to use the Dummy.TestPackage pushed earlier, so that you put this
 into `paket.dependencies` file:
```
nuget Dummy.TestPackage >= 0.1.331
```
 you have to push all the dependencies of `Dummy.TestPackage` into Klondike.
 (Run `mono .paket/paket.exe --verbose update` when your `paket.dependencies` is:
```
source https://nuget.org/api/v2

nuget System.Collections
nuget Dummy.TestPackage >= 0.1.331
```
