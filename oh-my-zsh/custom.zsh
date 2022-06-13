# custom alias list
alias rmproxy="export http_proxy=;export https_proxy="
alias k="kubectl"
alias kd="kubectl describe"
alias kdel="kubectl delete"
alias kc="kubectl create"
alias gs="git status"
alias glh="git log --graph --oneline --decorate | head"
# custom functions
kg() {
  command kubectl get -o wide "$@"
}
kgp() {
  command kubectl get pods -o wide "$@"
}
kgpa(){
  command kubectl get pods -A -o wide
}
touch () {
    command touch "$@" && code "$@"
}

function hex2ip() {
  printf '%d.%d.%d.%d\n' $(echo $1 | sed 's/../0x& /g')
}

function ip2hex() {
  printf '%02x%02x%02x%02x' $(echo $1  | awk -F. '{print $1" "$2" "$3" "$4}')
}

function kgse() {
  kubectl get secret $1 -o go-template='{{range $k,$v := .data}}{{"### "}}{{$k}}{{"\n"}}{{$v|base64decode}}{{"\n\n"}}{{end}}'
}

function kgs() {
  kubectl get svc $@
}

function kge() {
  kubectl get ep $@
}

function kaf() {
  kubectl apply -f $@
}
function kgn() {
  kubectl get nodes -owide
}

function kgetall {
  for i in $(kubectl api-resources --verbs=list --namespaced -o name | grep -v "events.events.k8s.io" | grep -v "events" | sort | uniq); do
    echo "Resource:" $i
    kubectl get ${i} --ignore-not-found -n ${1}
  done
}

function kcidr() {
 # kubectl get nodes -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' | xargs -I {} sh -c 'kubectl get node {} -o yaml | grep -E "^  name:|podCIDR: [0-9]" '
 kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.spec.podCIDR}{"\n"}' 
}

function ke() {
  kubectl exec -it $@ -- sh
}

function kec() {
  name=$1
  shift
  cmd=$@
  kubectl exec $name -- sh -c "$cmd"
}

function kdumpips() {
  kubectl cluster-info dump | grep -e 'service-cluster-ip-range' -e 'cluster-cidr' -m 2
}

function kgi(){
  # kubectl set image deployment/nginx-deployment nginx=nginx:1.16.1
  kubectl get pods --all-namespaces -o jsonpath="{.items[*].spec.containers[*].image}" -l $1 | tr -s '[[:space:]]' '\n' | sort | uniq -c
}

function krmp () {
  kubectl get pods -n ${2-kube-system} -l $1 -o=jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | xargs -I {} -n 1 kubectl delete pod {} -n ${2-kube-system}
}

function khelp(){
runpod=$(cat << 'EOF'
# -- Run a pod in one line and assign to specific Node.
kubectl run netshoot1 --image nicolaka/netshoot --restart=Never --overrides='{"spec": {"nodeSelector":{"kubernetes.io/hostname":"lan-k8s-0-1"}}}' -- tail -f /dev/null
# -- Get service cidr
kubectl cluster-info dump | grep -m 1 service-cluster-ip-range
# -- Get cluster cidr
kubectl cluster-info dump | grep -m 1 cluster-cidr
# -- Get each node' pod subnet
kubectl get nodes -A -o jsonpath='{range .items[*]}{.spec.podCIDR}{"\\n"}{end}'
# -- Get each pod's ip, use " | " as delimiter
kubectl get pods -A -o jsonpath='{range .items[*]}{.metadata.namespace}{"/"}{.metadata.name}{" | "}{.status.podIP}{"\\n"}{end}'
# -- Patch
kubectl patch deployment antrea-mc-controller -p '{"spec":{"template":{"spec":{"nodeSelector":{"kubernetes.io/hostname":"lan-k8s-0-0"}}}}}'
# -- patch to remove finalizer
kubectl patch resourceexport/clusterinfo -n kube-system --type json --patch='[ { "op": "remove", "path": "/metadata/finalizers" } ]'
# -- batch deletion
kubectl get resourceexport -n kube-system -o custom-columns=:metadata.name --no-headers | xargs -I {} -n 1 kubectl delete resourceexport {} -n kube-system
# -- remove taint
kubectl taint nodes --all node-role.kubernetes.io/control-plane- node-role.kubernetes.io/master-
EOF
)
echo $runpod
}

function nsenter-ctn () {
    CTN=$1  # container ID or name
    PID=$(sudo docker inspect --format "{{.State.Pid}}" $CTN)
    shift 1 # remove the first argument, shift others to the left
    nsenter -t $PID $@
}

function dgip(){
  docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $1
}

function dgips(){
  docker inspect -f '{{$.Name}} {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker ps -q)
}

function dnsenter {
  container_pid=$(docker inspect --format '{{ .State.Pid }}' $(docker ps | grep "$1" | awk '{print $1}'))
  nsenter -t $container_pid -n -u
}

function dpid() {
  docker inspect --format "{{ .State.Pid }}" $1
}

function du1(){
  os=$(uname)
  if [[ $os == "Darwin" ]];then
    du -h -d 1 | sort -hr
  fi
  if [[ $os == "Linux" ]];then
     du -h --max-depth=1 | sort -hr
  fi
}

function utils(){
text=$(cat << 'EOF'
#convert yaml to one line json
yq -o=json -I=0 '.' ~/workspaces/tmp/patch.yml
EOF
)
echo $text
}

