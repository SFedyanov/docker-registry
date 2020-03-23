#!/bin/bash

main () {
  initEnv 
  getImageArray
  pullImages
}

################# ENVS
initEnv() {
  . sync.env
  prepareSourceRepoUrl
  imagesArray=()
}

prepareSourceRepoUrl() {
  sourceRepoUrl="https://${SOURCE_REPO_LOGIN}:${SOURCE_REPO_PASSWORD}@${SOURCE_REPO_URL}/v2"
}
#################

################# Prepare images list
getRegistryList () {
  registryList="$(wget -qO- ${sourceRepoUrl}/_catalog)"
  echo $registryList
}

convertRepoListToArray () {
  echo $(echo $1 | ./jq -r '."repositories"[]')
}

loopByImageArray () {
  for image in $(convertRepoListToArray $(getRegistryList))
  do
    loopByImageTags 
  done
}

getImageTags () {
  imageTags="$(wget -qO- ${sourceRepoUrl}/${1}/tags/list)"
  echo $imageTags
}

convsertImageTagsToArray () {
  echo $(echo $1 | ./jq -r '."tags"[]')
}

loopByImageTags () {
  for tag in $(convsertImageTagsToArray $(getImageTags $image))
  do
    echo $image:${tag}
    imagesArray+="$image:${tag} "
  done
}

getImageArray () {
  echo "Preparing list of images..."
  loopByImageArray #"loopByImageTags" "docker pull" "${SOURCE_REPO_URL}" "/${image}:${tag}" "2"
  echo "Done."
}

##################

################## Pull images

pullImages() {
  echo "Pulling images..."
  for i in $imagesArray
  do
    echo "Pulling $i"
    docker pull ${SOURCE_REPO_URL}/$i
  done
  echo "Done."
}

#################


main
