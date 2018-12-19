pipeline {
  agent {
    label 'jenkins-slave-erlang'
  }

  stages {
    stage('Build & Test') {
      steps {
        sh 'rebar3 compile'
        sh 'rebar3 eunit'
        sh 'rebar3 release'
      }
    }

    stage('Build Image') {
      steps {
        script {
          openshift.withCluster() {
            openshift.withProject(ciProject) {
              openshift.selector('bc', 'erlang-app').startBuild("--from-file=_build/default/rel/idttcp/idttcp-0.0.1.tar.gz", '--wait')
            }
          }
        }
      }
    }
  }
}