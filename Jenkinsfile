pipeline {
  agent {
    label 'jenkins-slave-erlang'
  }

  stages {
    stage('Build & Test') {
      steps {
        sh 'rebar3 compile'
        sh 'rebar3 eunit'
      }
    }
  }
}