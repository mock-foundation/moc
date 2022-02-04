# CI/CD

Docs on Continious Integration/Development via [Github Actions](.github/workflows)


## [build.yml](.github/workflows/build.yml)
This action provides a release build on each push or pull request to `master` branch.

### master workflow
CI will build the app with Release configuration and provided `API_ID` and `API_HASH` secrets. 
*In case secrets not found, script will use official MacOS API_ID and API_HASH to make build valid.*

Then CI will create Github Release using `APP_VERSION` as a git tag and generate changelog. **Version must be incremented manualy in related Pull Request.**
App binary will be attached to release as well.

### PR workflow
Same as master workflow. The only change is that Github releases are not created.
Anybody can access the build via run artifacts.