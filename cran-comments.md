## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

## Test environments

* Local Windows 10 machine, R 4.4.1
* R-hub: Windows (release), Fedora Linux, Ubuntu, macOS (Intel)
* GitHub Actions: ubuntu-latest (devel, release)

## R CMD check results

There were no ERRORs or WARNINGs.

There was 1 NOTE:

> checking for future file timestamps ... NOTE 
unable to verify current time

## Comments

* The NOTE "unable to verify current time" appears to be related to the system's timestamp verification during the build process. This is likely due to the build environment's time synchronization or file system characteristics, and does not indicate any issue with the package itself. All files in the package have valid timestamps and the package builds correctly.

* Additionally, there was a warning during the build related to Quarto execution on Windows. This warning is external to the package and occurs when the system attempts to query Quarto's version. It does not affect the package functionality or the R CMD check results. The package does not depend on Quarto for its core functionality.

## About terms and acronyms in the package

* The package provides easy access to Brazilian macroeconomic and financial data. To clarify:

  - **SELIC** or **Selic** refers to the *Sistema Especial de Liquidação e Custódia*, which is the Brazilian central bank’s base interest rate, equivalent to the policy rate.
  - **Desemprego** means *unemployment*, a key labor market indicator widely used in economics.

* These terms are standard in Brazilian economic analysis and are either proper names or institutional acronyms, and thus intentionally not translated or modified. We opted to preserve these names for clarity and accuracy in data interpretation.

* All time and date outputs follow the system's locale. If any NOTE related to date/time output (e.g., localized day or month names) appear*



