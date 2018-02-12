#!/usr/bin/env bash
# bootstrap a kubernetes cluster using kubespray

set -e

__ScriptVersion="2018.02.12"
__ScriptName="bootstrap-k8s.sh"

export ANSIBLE_HOST_KEY_CHECKING=False


#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  echoerr
#   DESCRIPTION:  Echo errors to stderr.
#----------------------------------------------------------------------------------------------------------------------
echoerror() {
    printf "${RC} * ERROR${EC}: %s\n" "$@" 1>&2;
}

#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  echoinfo
#   DESCRIPTION:  Echo information to stdout.
#----------------------------------------------------------------------------------------------------------------------
echoinfo() {
    printf "${GC} *  INFO${EC}: %s\n" "$@";
}

__check_required_opts() {
# make sure all opts have been specified
  if [ -z "$_K8S_NODE" ]; then
    echoerror "_K8S_NODE variable not set. Please set it."
    error=1
  fi
  if [ -z "$_K8S_ETCD" ]; then
    echoerror "_K8S_ETCD variable not set. Please set it."
    error=1
  fi
  if [ -z "$_K8S_MASTER" ]; then
    echoerror "_K8S_MASTER variable not set. Please set it."
    error=1
  fi
  if [ -z "$_PASSWORD" ]; then
    echoerror "_PASSWORD variable not set. Please set it."
    error=1
  fi
  if [[ ${error} == 1 ]]; then
    __usage
    exit 1
  fi
}

__usage() {
    cat << EOT

  Usage :  ${__ScriptName} [args]

  Examples:
    - ${__ScriptName} -n node1.example.com -n node2.your.domain.com -e node1.your.domain.com -e node2.your.domain.com -m node3.your.domain.com
    - bash ${__ScriptName} -u solidfire -p solidfire \\
                            -n kubenode1.your.domain.com \\
                            -n kubenode2.your.domain.com \\
                            -n kubenode3.your.domain.com \\
                            -e kubenode1.your.domain.com \\
                            -e kubenode2.your.domain.com \\
                            -e kubenode3.your.domain.com \\
                            -m kubenode1.your.domain.com

  Options:
    -h  Display this message
    -v  Display script version
    -n  FQDN to be k8s node
    -e  FQDN to be k8s etcd
    -m  FQDN to be k8s master
    -u  username to connect with
    -p  password to connect with
EOT
}   # ----------  end of function __usage  ----------


while getopts ':hvn:e:m:u:p:' opt
do
  case "${opt}" in
    h )  __usage; exit 0                                ;;
    v )  echo "$0 -- Version $__ScriptVersion"; exit 0  ;;
    n )  _K8S_NODE+=("$OPTARG")                         ;;
    e )  _K8S_ETCD+=("$OPTARG")                         ;;
    m )  _K8S_MASTER+=("$OPTARG")                       ;;
    u )  _USERNAME=$OPTARG                              ;;
    p )  _PASSWORD=$OPTARG                              ;;
    \?)  echo
         echoerror "Option does not exist : $OPTARG"
         __usage
         exit 1
         ;;
    :)
         echo "Option -$OPTARG requires an argument." >&2
         exit 1
         ;;
  esac    # --- end of case ---
done
shift $((OPTIND-1))

# preflight checks
__check_required_opts

cd; git clone https://bitbucket.org/solidfire/kubespray-and-pray.git || cd kubespray-and-pray
ansible_playbook_cmd_opts="-e ansible_user=${_USERNAME} -e ansible_ssh_pass=${_PASSWORD}"


node_hostn=($(printf "%s\n" "${_K8S_NODE[@]/.*/}"))
etcd_hostn=($(printf "%s\n" "${_K8S_ETCD[@]/.*/}"))
master_hostn=($(printf "%s\n" "${_K8S_MASTER[@]/.*/}"))
all_k8s="${_K8S_NODE[@]} ${_K8S_ETCD[@]} ${_K8S_MASTER[@]}"
all_k8s_uniq=($(echo $(echo -e "${all_k8s// /\\n}" | sort -u)))
all_hostn=($(printf "%s\n" "${all_k8s_uniq[@]/.*/}"))
all_k8s_uniq_str=$(printf "%s " "${all_k8s_uniq[@]}")
all_k8s_uniq_comma_delimit=$(echo ${all_k8s_uniq_str}| sed 's/ /,/g'),
all_k8s_pre_post=$(echo "${all_k8s_uniq_comma_delimit/$(hostname -f),/}")


printf "%s\n" "${_PASSWORD}"|sudo -S bash -c 'apt -y install python-pip git sshpass|| apt update; apt -y install python-pip git sshpass'
sudo -H pip install ansible
sudo -H pip install kubespray
cp $(find / -name .kubespray.yml 2>/dev/null|head -n1) ~
cd ~/kubespray-and-pray
cat <<EOF > inventory/inventory.cfg
[kube-master]
$(for i in ${!_K8S_MASTER[*]}; do printf "%s         ansible_ssh_host=%s\n" "${master_hostn[i]}" "${_K8S_MASTER[i]}"; done)

[all]
$(for i in ${!all_k8s_uniq[*]}; do printf "%s         ansible_ssh_host=%s\n" "${all_hostn[i]}" "${all_k8s_uniq[i]}"; done)

[k8s-cluster:children]
kube-node
kube-master

[kube-node]
$(for i in ${!_K8S_NODE[*]}; do printf "%s         ansible_ssh_host=%s\n" "${node_hostn[i]}" "${_K8S_NODE[i]}"; done)

[etcd]
$(for i in ${!_K8S_ETCD[*]}; do printf "%s         ansible_ssh_host=%s\n" "${etcd_hostn[i]}" "${_K8S_ETCD[i]}"; done)
EOF

ansible-playbook "${ansible_playbook_cmd_opts}" -i "localhost," -c local bootstrap.yml user-solidfire.yml ubuntu-pre.yml
ansible-playbook "${ansible_playbook_cmd_opts}" -i "${all_k8s_pre_post}" bootstrap.yml user-solidfire.yml ubuntu-pre.yml


kubespray prepare --nodes   $(for i in ${!_K8S_NODE[*]}; do printf "%s[ansible_ssh_host=%s] " "${node_hostn[i]}" "${_K8S_NODE[i]}"; done) \
                  --etcds   $(for i in ${!_K8S_ETCD[*]}; do printf "%s[ansible_ssh_host=%s] " "${etcd_hostn[i]}" "${_K8S_ETCD[i]}"; done) \
                  --masters $(for i in ${!_K8S_MASTER[*]}; do printf "%s[ansible_ssh_host=%s] " "${master_hostn[i]}" "${_K8S_MASTER[i]}"; done)
kubespray deploy -y

ansible-playbook "${ansible_playbook_cmd_opts}" -i "localhost," -c local ubuntu-post.yml || true
ansible-playbook "${ansible_playbook_cmd_opts}" -i "${all_k8s_pre_post}" ubuntu-post.yml || true
