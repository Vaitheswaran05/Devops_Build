pipeline {
  agent any
  environment {
    DOCKER_USER = 'vaith'
    DH_CRED = 'docker-hub-credentials'
    EC2_CRED = 'ec2-user'
    EC2_HOST = '<13.203.76.212>'  
  }
  stages {

    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Build Image') {
      steps {
        sh "docker build -t ${DOCKER_USER}/devops-build-react-app:latest ."
      }
    }

    stage('Push Dev Image') {
      when { branch 'dev' }
      steps {
        withCredentials([usernamePassword(credentialsId: "${DH_CRED}", usernameVariable: 'DU', passwordVariable: 'DP')]) {
          sh 'echo $DP | docker login -u $DU --password-stdin'
          sh "docker tag ${DOCKER_USER}/devops-build-react-app:latest ${DOCKER_USER}/dev:latest"
          sh "docker push ${DOCKER_USER}/dev:latest"
        }
      }
    }

    stage('Push Prod & Deploy') {
      when { branch 'master' }
      steps {
        withCredentials([usernamePassword(credentialsId: "${DH_CRED}", usernameVariable: 'DU', passwordVariable: 'DP')]) {
          sh 'echo $DP | docker login -u $DU --password-stdin'
          sh "docker tag ${DOCKER_USER}/devops-build-react-app:latest ${DOCKER_USER}/prod:latest"
          sh "docker push ${DOCKER_USER}/prod:latest"
        }

        withCredentials([sshUserPrivateKey(credentialsId: "${EC2_CRED}", keyFileVariable: 'KEYFILE', usernameVariable: 'EC2_USER')]) {
          sh "ssh -o StrictHostKeyChecking=no -i ${KEYFILE} ${EC2_USER}@${EC2_HOST} 'sudo docker pull ${DOCKER_USER}/prod:latest && sudo docker rm -f react-prod || true && sudo docker run -d -p 80:80 --name react-prod ${DOCKER_USER}/prod:latest'"
        }
      }
    }

  }
}