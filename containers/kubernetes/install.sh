kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule \
	--clusterrole=cluster-admin \
	--serviceaccount=kube-system:tiller
helm init --service-account tiller --upgrade
kubectl patch deploy --namespace kube-system tiller-deploy \
	-p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'

sleep 10

helm install stable/nginx-ingress --name nginx-ingress \
	--namespace kube-system \
	--set rbac.create=true \
	--set controller.service.loadBalancerIP="35.197.58.26"
