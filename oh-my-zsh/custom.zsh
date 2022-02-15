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
kg() {
  command kubectl get -o wide "$@"
}
kgp() {
  command kubectl get pods -o wide "$@"
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

function inspect() {
  docker inspect --format "{{ .State.Pid }}" $1
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

function nsenter-ctn () {
    CTN=$1  # container ID or name
    PID=$(sudo docker inspect --format "{{.State.Pid}}" $CTN)
    shift 1 # remove the first argument, shift others to the left
    nsenter -t $PID $@
}

function rmp () {
  kubectl get pods -l $1 -o=jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | xargs -n 1 kubectl delete pod
}