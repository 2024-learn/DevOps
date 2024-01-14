#!/user/bin/env groovy
def call (){
  echo "building the docker image"
  withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
    sh 'docker build -t phyllisn/jma:jma-2.0 .'
    sh 'echo $PASS | docker login -u $USER --password-stdin'
    sh 'docker push phyllisn/jma:jma-2.0'
  }
}