# export list

# custom alias list
alias rmproxy="export http_proxy=;export https_proxy="
alias k="kubectl"
alias kd="kubectl describe"
alias kdel="kubectl delete"
alias kc="kubectl create"
alias gs="git status"
alias glh="git log --graph --oneline --decorate | head"
# custom functions
# kubectl
function kg() {
  command kubectl get -o wide "$@"
}

function kgp() {
  command kubectl get pods -o wide "$@"
}

function kgs() {
  kubectl get secret $1 -o go-template='{{range $k,$v := .data}}{{"### "}}{{$k}}{{"\n"}}{{$v|base64decode}}{{"\n\n"}}{{end}}'
}

function kgn() {
  kubectl get nodes -owide
}

function kgetall {
  for i in $(kubectl api-resources --verbs=list --namespaced -o name | grep -v "events.events.k8s.io" | grep -v "events" | sort | uniq); do
    echo "Resource:" $i
    kubectl get ${i} -n ${1} 
  done
}

function rmp () {
  kubectl get pods -l $1 -o=jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | xargs -n 1 kubectl delete pod
}

function getimgs(){
  # kubectl set image deployment/nginx-deployment nginx=nginx:1.16.1
  # https://kubernetes.io/docs/tasks/access-application-cluster/list-all-running-container-images/
  kubectl get pods --all-namespaces -o jsonpath="{.items[*].spec.containers[*].image}" -l $1 | tr -s '[[:space:]]' '\n' | sort | uniq -c
}

# docker
function nsenter-ctn () {
    CTN=$1  # container ID or name
    PID=$(sudo docker inspect --format "{{.State.Pid}}" $CTN)
    shift 1 # remove the first argument, shift others to the left
    nsenter -t $PID $@
}

function getpid() {
  docker inspect --format "{{ .State.Pid }}" $1
}

function getip(){
  docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $1
}

function getips(){
  docker inspect -f '{{$.Name}} {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker ps -q)
}

function cleanup(){
  docker ps --filter status=exited -q | xargs docker rm
}

# network utils
function hex2ip() {
  printf '%d.%d.%d.%d\n' $(echo $1 | sed 's/../0x& /g')
}

function ip2hex() {
  printf '%02x%02x%02x%02x' $(echo $1  | awk -F. '{print $1" "$2" "$3" "$4}')
}

# misc
function touch () {
    command touch "$@" && code "$@"
}

# list and sort directory based on disk size
function du1(){
  os=$(uname)
  if [[ $os == "Darwin" ]];then
    du -h -d 1 | sort -hr
  fi
  if [[ $os == "Linux" ]];then
     du -h --max-depth=1 | sort -hr
  fi
}