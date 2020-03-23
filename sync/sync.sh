#!/bin/bash

main () {
  printf "\nDocker repositrory synchronization script \n\n" 
  initEnv 
  getImageArray
  #pullImages
  setTags
  pushImages
  removeTags
}

################# ENVS
initEnv() {
  workDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" 
  printf "Script working directory is: $workDir\n\n"
  cd $workDir
  . sync.env
  prepareSourceRepoUrl
  prepareDestRepoUrl
  imagesArray=()
}


prepareSourceRepoUrl() {
  sourceRepoUrl="https://${SOURCE_REPO_LOGIN}:${SOURCE_REPO_PASSWORD}@${SOURCE_REPO_URL}"
  printf "Source repository URL is: $sourceRepoUrl\n\n"
}

prepareDestRepoUrl() {
  destRepoUrl="https://${DEST_REPO_LOGIN}:${DEST_REPO_PASSWORD}@${DEST_REPO_URL}"
  printf "Destinathion repository URL is: $destRepoUrl\n\n"
}

#################

################# Prepare images list
getRegistryList () {
  registryList="$(wget -qO- ${sourceRepoUrl}/v2/_catalog)"
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
  imageTags="$(wget -qO- ${sourceRepoUrl}/v2/${1}/tags/list)"
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
  printf "Preparing list of images...\n\n"
  #loopByImageArray 
  imagesArray="ifalcon/aerospike:3.3.3 ifalcon/doc_ocr:latest ifalcon/facestream-service:latest ifalcon/hatandbeard:latest ifalcon/ifalcon-server:latest ifalcon/ifalcon-ui:latest ifalcon/ifalcon-ui:showcase ifalcon/luna-admin:3.3.3 ifalcon/luna-api:3.3.3 ifalcon/luna-broker:3.3.3 ifalcon/luna-extractor:3.3.3 ifalcon/luna-faces:3.3.3 ifalcon/luna-facestream:3.3.3 ifalcon/luna-imagestore:3.3.3 ifalcon/luna-matcher:3.3.3 ifalcon/luna-ui:3.3.3 ifalcon/postgres:11.5 ifalcon/postgres:9.6 ifalcon/rabbitmq:3.7.17-management ifalcon/rabbitmq:management ifalcon/reports:latest ifalcon/rtsp:latest"
  echo "imagesArray=$imagesArray"
  printf "Done.\n\n"
}

##################

################## Pull images

pullImages() {
  printf "Pulling images...\n\n"
  for i in $imagesArray
  do
    echo "Pulling $i"
    docker pull ${SOURCE_REPO_URL}/$i
  done
  printf "Done.\n\n"
}

#################

################# Set tags

setTags() {
  printf "Set tags...\n\n"
  for i in $imagesArray
  do
    echo "Tag for $i"
    docker tag $SOURCE_REPO_URL/$i $DEST_REPO_URL/$i
  done
  printf "Done.\n\n"
}

#################

################# Push images

pushImages() {
  printf "Push images...\n\n"
  docker login --username $DEST_REPO_LOGIN --password $DEST_REPO_PASSWORD $DEST_REPO_URL
  for i in $imagesArray
  do
    echo "Push imag $i"
    docker push $DEST_REPO_URL/$i
  done
  docker logout $DEST_REPO_URL
  printf "Done.\n\n"
}

#################

################# Remove tags

removeTags () {
  printf "Remove tags...\n\n"
  for i in $imagesArray
  do
    echo "Remove tag $i"
    docker rmi $DEST_REPO_URL/$i
  done
  printf "Done.\n\n"
}

#################


main
