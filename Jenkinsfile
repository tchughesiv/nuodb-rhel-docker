//def tag_prefix=env.BRANCH_NAME.replaceAll(/[^a-zA-Z0-9_]/,"_")
// This should really come from branch name

def tag_prefix=""

def awsPushCredentials="build-jenkins-oa"
def nuodbRepo=env.REPOSITORY
def region="us-east-1"

def dockerhubPushCredentials="docker.io-nuodb-push"

def redhatPushCredentials="redhat.nuodb.push"
def redhatRepo="https://registry.rhc4tp.openshift.com"

def release_build=env.RELEASE_BUILD
def release_package=env.RELEASE_PACKAGE
def build=env.RELEASE_BUILD_NUMBER

    // A map of build arguments that will be passed to docker
def BUILDARGS = [ "RELEASE_BUILD": release_build,
		  "RELEASE_PACKAGE": release_package,
		  "BUILD": build,
		  ]
    /**  A list of version numbers used to build tags.  See #buildTags for details
     */
def VersionArray = [ release_build, release_package, build, env.BUILD_NUMBER]
		 



    /** Build a list of tags from an array of version numbers.
     *
     * The array is built by concatenating as follows: (1,2,3) becomes
     * ("1", "1.2", "1.2.3")
     *
     */

def buildTags(array) {
    def strings=[]
    def last
    array.each { s->
	       if(last) {
		   last = last + "-" + s
	       }
	       else {
		   last = s
	       }
	       strings << last
    }

    return strings.reverse()
}


/**
 * standardPush -- push the given image to the given repository with
 * all the usuall tags.
 */

def standardPush(label, imageName, tag_prefix, repo, credentials, tags) {

    def image = docker.image(imageName)

    docker.withRegistry(repo, credentials) {
	stage("Push ${imageName} to ${label}") {
	    tags.each {
		echo "docker push ${imageName} ${repo}/${imageName}:${tag_prefix}${it}"
		image.push("${tag_prefix}${it}")
	    }
	}
    }
}

/** Perform the actual build, with full build arguments
 */
def performBuild(image, args, imageName=null) {
	stage("Build ${image}") {
	    def buildargs = args.collect { k, v -> k + "=" + v }.join(" --build-arg ") 

            if(!imageName) {
		imageName=image
	    }

	    sh "docker build -t ${imageName} --build-arg RHUSER=${RHUSER} --build-arg RHPASS=${RHPASS} --build-arg VERSION=${image} --build-arg ${buildargs} ."

	}
}

// On a node which has docker
node('docker') {

    stage('checkout') {
	checkout scm
    }

    //////////////////////////////////////////////////////////////////////
    //
    // Build both the NuoDB (full) image and the NuoDB-CE image
    //
    //////////////////////////////////////////////////////////////////////

    withCredentials([usernamePassword(credentialsId: 'redhat.subscription', passwordVariable: 'RHPASS', usernameVariable: 'RHUSER')]) {
	performBuild("nuodb", BUILDARGS)
	performBuild("nuodb-ce", BUILDARGS, "nuodb/nuodb-ce")
	performBuild("nuodb-ce", BUILDARGS, "${env.REDHAT_KEY}/nuodb-ce")
    }

    //////////////////////////////////////////////////////////////////////
    //
    //      The NuoDB (full) docker image can only go to AWS ECR
    //
    //////////////////////////////////////////////////////////////////////

    def tagSet = buildTags(VersionArray)
    standardPush("ECR", "nuodb", tag_prefix, nuodbRepo, "ecr:${region}:${awsPushCredentials}", tagSet)

    //////////////////////////////////////////////////////////////////////
    //
    //      The NuoDB-CE image can be pushed to docker hub and to
    //      RedHat repository
    //
    //////////////////////////////////////////////////////////////////////

    standardPush("docker hub", "nuodb/nuodb-ce", tag_prefix, "", dockerhubPushCredentials, tagSet)
    standardPush("RedHat", "${env.REDHAT_KEY}/nuodb-ce", tag_prefix, redhatRepo, redhatPushCredentials, tagSet)
}
