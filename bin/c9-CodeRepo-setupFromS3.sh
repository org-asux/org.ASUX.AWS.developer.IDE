#!/bin/false

### ATTENTION.  Before modifying this file, you ___MUST___ edit the companion file: c9-CodeRepo-setup.sh

###--------------
### LINUX/C9-CLI:       <----------
###--------------

###             export PROJECTID=...
###             export ENV=...

###             S3_BUCKETNAME=...
###             S3_BUCKETNAME=${PROJECTID}
###             S3_BUCKETNAME=${PROJECTID}-${ENV}    <--- Pick _ONLY_ one of these 3 lines !!!!

###             AWSREGION="us-east-1"

###             export AWSPROFILE="default"
###             export AWSPROFILE=${PROJECTID}-${ENV}-ADMIN
###             aws sso login .. ..                  <---- On Cloud9-IDE?   No need to run this command!
###             STD_AWSOPTIONS=""                    <---- On Cloud9-IDE?   Use this "empty" value, instead of following line!
###             STD_AWSOPTIONS="--region ${AWSREGION} --profile ${AWSPROFILE}"
###             STDARGS=${STD_AWSOPTIONS}

### Download this file, and upload it into C9-IDE as:-
###             aws s3 cp "./devtools/bin/c9-CodeRepo-setupFromS3.sh" s3://${S3_BUCKETNAME}/devtools/bin/  ${STD_AWSOPTIONS}

###----------------------------------------------------------------------------------

###-----------
### WINDOWS:           <----------
###-----------

###             SET PROJECTID=...
###             SET ENV=...

###             SET S3_BUCKETNAME=...
###             SET S3_BUCKETNAME=%PROJECTID%
###             SET S3_BUCKETNAME=%PROJECTID%-%ENV%    <--- Pick _ONLY_ one of these 3 lines !!!!

###             SET AWSREGION=us-east-1

###             SET AWSPROFILE=default
###             SET AWSPROFILE=%PROJECTID%-%ENV%-ADMIN
###             SET STD_AWSOPTIONS=--region %AWSREGION%  --profile %AWSPROFILE%





### AFTER UPDATING this file, upload it to SHARED S3-location (CLI on C9-IDE) as:-
###             aws s3 cp .\devtools\bin\c9-CodeRepo-setupFromS3.sh s3://%S3_BUCKETNAME%/devtools/bin/      %STD_AWSOPTIONS%





### =========================================================
### @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
### =========================================================

if [ -z ${PROJECTID+X} ]; then echo "Env-Variable PROJECTID is missing. please follow instructions @ file://./devtools/bin/c9-CodeRepo-setup.sh"; exit 1; fi
if [ -z ${USERID+X} ]; then echo "Env-Variable USERID is missing. please follow instructions @ file://./devtools/bin/c9-CodeRepo-setup.sh"; exit 1; fi

if [ -z "${AWSPROFILE+x}" ]; then
    echo '!! ERROR !! AWSPROFILE is NOT defined as an ENV-Variable.  Typically: it should be === "default" or "${PROJECTID}-${ENV}_sso_admin"'
    sleep 300
    return
fi

### -----
SSMPARAMPREFIX_CODEREPO="/${PROJECTID}"        ### ATTN: Don't include ${ENV} in the expression!  Code-Repo is same across ENV.

GITHUB_RAW_URL="https://raw.githubusercontent.com/org-asux/org.ASUX.AWS.developer.IDE/main/bin/CodeRepo"
### gitlab -> GITLAB_RAW_URL="https://gitlab.com/user/PROJECTID/raw/main/path2Folder/filename"

### =========================================================
### @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
### =========================================================

### ---------- CONFIGURE CLI for Subversion/SVN -------------
MyCodeRepoSetupScript=~/c9-CodeRepo-setup.sh     ### WARNING: Do not put the value in QUOTES. Why? Reason: The ~ character.
SVNCONFDIR=~/.subversion                         ### WARNING: Do not put the value in QUOTES. Why? Reason: The ~ character.
SVNCONF=${SVNCONFDIR}/servers
mkdir -p ${SVNCONFDIR}

grep --quiet '^\[global\]$' ${SVNCONF} >& /dev/null
SVNCONFIGURED_1=$?
grep --quiet '^store-plaintext-passwords' ${SVNCONF} >& /dev/null
SVNCONFIGURED_2=$?

if [ -e ${SVNCONF} ] && [ ${SVNCONFIGURED_1} = 0 ]; then
    echo "Subversion CLI is already initialized - re: [global]"
else
    echo "[global]" > ${SVNCONF}
fi
if [ -e ${SVNCONF} ] && [ ${SVNCONFIGURED_2} = 0 ]; then
    echo "Subversion CLI is already initialized - re: store-paswd"
else
    echo "store-plaintext-passwords=no" >> ${SVNCONF}
fi

### ------------ CONNECT to CODE-REPO -------------
export REPO_USERID=$(aws ssm get-parameter --name ${SSMPARAMPREFIX_CODEREPO}/CODE-REPO-USERID-${USERID} --with-decryption --region ${AWSREGION} --profile ${AWSPROFILE} | jq -c ".Parameter.Value" --raw-output)
export REPO_PASSWORD=$(aws ssm get-parameter --name ${SSMPARAMPREFIX_CODEREPO}/CODE-REPO-PASSWORD-${USERID} --with-decryption --region ${AWSREGION} --profile ${AWSPROFILE} | jq -c ".Parameter.Value" --raw-output )

echo REPO_USERID=${REPO_USERID}
echo REPO_PASSWORD=${REPO_PASSWORD}

### ------------ "pull" the "other" file from Code-Repo -------------
echo \
curl -o ${MyCodeRepoSetupScript} "${GITHUB_RAW_URL}/${MyCodeRepoSetupScript}"
curl -o ${MyCodeRepoSetupScript} "${GITHUB_RAW_URL}/${MyCodeRepoSetupScript}"
# pushd ~
# svn export   ${GITHUB_RAW_URL}/devtools/c9-CodeRepo-setup.sh --username=${REPO_USERID} --password=${REPO_PASSWORD} --force > /dev/null
# popd

### ------------ UPDATE the "other" file -------------
cat ${MyCodeRepoSetupScript} | sed -e "s/^export PROJECTID=\"[a-zA-Z0-9_-][a-zA-Z0-9_-]*\"$/export PROJECTID=\"${PROJECTID}\"/" > /tmp/o
mv /tmp/o  ${MyCodeRepoSetupScript}

cat ${MyCodeRepoSetupScript} | sed -e "s/^export USERID=\"[a-zA-Z0-9_-][a-zA-Z0-9_-]*\"$/export USERID=\"${USERID}\"/" > /tmp/o
mv /tmp/o  ${MyCodeRepoSetupScript}


### ------------ FRIENDLY OUTPUT -------------
echo Example:      svn checkout '${REPO}  --username=${REPO_USERID} --password=${REPO_PASSWORD}'
echo Example:      git checkout 'https://${REPO_USERID}:${REPO_PASSWORD}@github.com/${REPO_USERID}/${REPONAME}'
echo Example:      git checkout 'https://${REPO_USERID}:${REPO_PASSWORD}@gitlab.com/${REPO_USERID}/${REPONAME} (gitLAB)'

## EoF
