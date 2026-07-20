# Introduction to CI/CD and GitHub Actions

## CI/CD - Continuous Integration / Continuous Deployment
- Continuous Integration: The flow in which developers upload their code frequently in a central repository (GitHub/GitLab); each modification triggers automatically a **pipeline** in cloud which tests the code, verifies syntax errors (linting) and builds the Docker image to ensure everything is stable
- Continuous Deployment: If all the tests in the CI phase pass, the pipeline takes the new Docker image and sends it automatically on the live servers (or Kubernetes clusters), with no human interaction

## GitHub Actions
- GitHub Actions is a automation platform directly intergrated into GitHub
- It is configured through **YAML** files
- **Workflow**: the completely automated process (ex. the testing pipeline); it is described in a `.yaml` file; a workflow is built of multiple actions
- **Event**: tells GitHub when to run the flow (ex. at every `push` on `main` branch); when something happens IN or TO a repository
- **Runner**: the cloud server from GitHub (usually a clean Ubuntu VM) where the commands will be executed
- **Job**: a series of steps that execute on the same Runner; a workflow may have multiple jobs that run concurrently; one job will run on one server at a time
- **Steps**: the individual commands executed sequentially (ex. running a script, installing a dependency or a simple `echo`)

- The GitHub Actions `.yaml` are placed in `/.github/workflows/`

## Syntax of a workflow file
(along with examples)
`name` - describes what the workflow is doing (optional)
```yaml
name: Java CI with Gradle
```
`on` - defines the events that trigger the workflow
```yaml
on:
  push:
    branches: [ master ]
  pull_request:
    branches: [ master ]
```
(see GitHub docs for more events)
`jobs` - groups a set of actions that will be executed; there can be one or more jobs
`strategy` - configuration block used to define how GitHub Actions should scale and manage the execution of a job
`matrix` - mechanism that automatically duplicates a job into multiple parallel runs based on all possible combinations of the variables we provide
`uses` - selects an **action**; under the `action/` path on GitHub, predefined actions are hosted on GitHub, actions are basically just normal repositories and many are already written by other users
`run` - is used for simple commands (ex. Linux commands)
`needs` - creates a dependency between separate jobs
```yaml
jobs:
  build:
    runs-on: ${{matrix.os}}
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macOS-latest]

    steps:
    - uses: actions/checkout@v2

    - name: Set up JDK 1.8
      uses: actions/setup-java@v1
      with:
          java-version: 1.8
    
    - name: Grant execute permission for gradlew
      run: chmod +x gradlew

    - name: Build with Gradle
      run: ./gradlew build

  publish:
    needs: build
```

## Building a Docker image and uploading to Docker Hub
- Using an action from GitHub
```yaml
    - name: Build and Push Docker Image
      uses: mr-smithers-excellent/docker-build-push@v4
      with:
        image: nanajanashia/demo-app
        registry: docker.io
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}
```