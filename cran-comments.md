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

> Found the following hidden files and directories:
  .Rhistory
  These were most likely included in error. See section ‘Package structure’ in the ‘Writing R Extensions’ manual.

## Comments

* The hidden `.Rhistory` file was created locally during development and has already been removed before submission. It is not included in the final tarball.

## About terms and acronyms in the package

* The package provides easy access to Brazilian macroeconomic and financial data, which includes common acronyms and terms in Portuguese and English. To clarify:

  - **SELIC** O **Selic** refers to the *Sistema Especial de Liquidação e Custódia*, which is the Brazilian central bank’s base interest rate, equivalent to the policy rate.
  - **IBGE** is the *Instituto Brasileiro de Geografia e Estatística*, Brazil’s national statistics agency.
  - **SIDRA** is the *Sistema IBGE de Recuperação Automática*, a system to retrieve statistical tables from IBGE.
  - **Desemprego** means *unemployment*, a key labor market indicator widely used in economics.

* These terms are standard in Brazilian economic analysis and are either proper names or institutional acronyms, and thus intentionally not translated or modified. We opted to preserve these names for clarity and accuracy in data interpretation.

* All time and date outputs follow the system's locale. If any NOTE related to date/time output (e.g., localized day or month names) appear*



