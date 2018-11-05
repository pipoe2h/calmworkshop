pushd ~/Documents/github.com/mlavi/stageworkshop/ \
&& source scripts/stageworkshop.lib.sh 'quiet'

if (( $(docker ps 2>&1 | grep Cannot | wc --lines) == 0 )); then
  docker run --rm -v "$(pwd):/repo" gittools/gitversion-fullfx:linux /repo \
  > ${RELEASE}
elif [[ ! -z $(which gitversion) ]]; then
  gitversion > ${RELEASE}
else
  echo "Error: Docker engine down and no native binary available on PATH."
fi

mv ${RELEASE} original.${RELEASE} && cat ${_} \
| jq ". + {\"PrismCentralStable\":\"${PC_VERSION_STABLE}\"} + {\"PrismCentralDev\":\"${PC_VERSION_DEV}\"}" \
> ${RELEASE} && rm -f original.${RELEASE}

git add ${RELEASE}
