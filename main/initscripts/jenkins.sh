echo "=======> [jenkins] installing jenkins components :"
kubectl apply -f jenkins/jenkins-deployment.yaml
kubectl apply -f jenkins/jenkins-clusterip.yaml

echo "=======> [jenkins] waiting for jenkins' pod to run :"
while [[ -z "`kubectl get pods | grep jenkins | grep Running`" ]]; do sleep 5; done

echo "=======> [jenkins] waiting for jenkins' web interface to run :"
while [[ -z "`curl jenkins.devops.[[DOMAIN]] | grep Authentication | grep required`" ]]; do sleep 5; done

echo "=======> [jenkins] printing jenkins' admin password :"
kubectl cp $( kubectl get pods | grep jenkins | tr -s ' ' | cut -d ' ' -f1 ):/var/jenkins_home/secrets/initialAdminPassword ./jenkinsInitialAdminPassword
cat jenkinsInitialAdminPassword
rm jenkinsInitialAdminPassword