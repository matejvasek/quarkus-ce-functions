#!/bin/bash

image="quay.io/boson/quarkus-ce-functions"

script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
base_dir=$(cd "${script_dir}/.." && pwd)
build_dir="${base_dir}/build"

patch=$(grep -P "^version:\s*\d+\.\d+\.\d+\s*$" ${base_dir}/stack.yaml | tr -d 'version: ')
major=$(echo ${patch} | cut -d . -f 1)
minor=${major}.$(echo ${patch} | cut -d . -f 2)
tag="v${patch}"

red='\033[0;31m'
green='\033[0;32m'
purple='\033[0;35m'
orange='\033[0;33m'
nc='\033[0m' # No Color

function success_or_bail {
  if [ ${1} != "0" ] ; then
    printf "${red}${2}${nc}\n\n"
    exit ${1}
  fi
}

local_repo=${HOME}/.appsody/stacks/dev.local
source_archive=${local_repo}/quarkus-ce-functions.${tag}.source.tar.gz
template_archive=${local_repo}/quarkus-ce-functions.${tag}.templates.default.tar.gz
repo_index=${local_repo}/boson-index.yaml

git tag ${tag}
success_or_bail $? "Failed to tag source repository: ${tag}"
printf "${green}Tagged source: ${tag}${nc}\n\n"

docker push ${image}:${patch}
success_or_bail $? "Failed to push image tag ${patch}"
printf "${green}Published ${image}:${patch}${nc}\n"

docker push ${image}:${minor}
success_or_bail $? "Failed to push image tag ${minor}"
printf "${green}Published ${image}:${minor}${nc}\n"

docker push ${image}:${major}
success_or_bail $? "Failed to push image tag ${major}"
printf "${green}Published ${image}:${major}${nc}\n"

docker push ${image}:latest
success_or_bail $? "Failed to push image tag latest"
printf "${green}Published ${image}:latest${nc}\n"

hub release create -a ${template_archive} -m "${tag}" ${tag}
success_or_bail $? "Failed to release templates"
printf "${green}Released ${tag} templates${nc}\n"

appsody stack add-to-repo boson --release-url https://github.com/boson-project/quarkus-ce-functions/releases/latest/download/
success_or_bail $? "Failed to update stack repo index"
printf "${green}Updated stacks repository index locally${nc}\n"

if [ ! -d ${build_dir} ] ; then
  mkdir -p ${build_dir}
  success_or_bail $? "Can't create build directory ${build_dir}"
fi

cp ${source_archive} ${build_dir}
success_or_bail $? "Can't copy source archive ${source_archive}"

cp ${template_archive} ${build_dir}
success_or_bail $? "Can't copy template archive ${template_archive}"

cp ${repo_index} ${build_dir}
success_or_bail $? "Can't copy index ${repo_index}"

printf "\n${orange}Congratulations, you have successfully published ${patch}."
printf "\n${orange}To make this update publicly available, release an updated boson stacks repository."
printf "\n${orange}  (see https://github.com/boson-project/stacks/#releasing)."
printf "\n\n${green}Now push the updates and tags:\n\n    ${purple}'git push origin release --follow-tags'${nc}\n"