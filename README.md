gitr - a branching model for multiple variants
==============================================

gitr let you manage multiple variants of your software, and makes it simple to
develop specific and (variant-) universal features.
It includes a staging from feature branch to experimental to stable, and also Hot- and Coldfix branches.

##Getting started
###Creating Variants
To start adding your first variants to your code simply init gitr by starting your universal variant and 
derive your other variants from it:

    gitr variant universal            #create special variant universal
    gitr variant platform-independend #create variant "platform-independend"
    gitr variant linux-only           #create another variant "linux-only"

The creation of a variant does basically two things

* create a experimental branch for this variant
* create a stable branch

To switch between variants use the same command as you used to create them.

###Creating Features

Now checkout the variant you want to work on and start creating features:

    gitr variant linux-only
    gitr feature tcp-layer

The first command selects the variant you want to extend, the second creates a feature branch named "tcp-layer".
Now you can start commiting your feature using normal git commands, -> git add, git commit

###Upmerge to experimental and keep your feature up to date

While your daily work, you should regulary fetch changes from the experimental branch.
To do so, you can use the "gitr update" command. This command updates the currently active branch.
So if you are on a feature branch "gitr update" will merge the experimental branch of the active variant into your feature.
If you are done with your feature, upmerge it into experimental. Therefore "gitr upmerge" is available.

Example:
    
    gitr variant linux-only
    gitr feature tcp-layer
    ...
    git add src/TCPLayer.h
    git commit -m "added tcp layer header"
    ...
    gitr update
    ...
    git add src/TCPLayer.cpp
    git commit -m "added tcp layer implementation"
    ...
    gitr upmerge


###Preparing a release

If you're fine with your features, it's time for the testing and correction phase before releasing it.
To do so, you upmerge your experimental to the testing branch and perform all your code tests on it. If you find some issues its time for a coldfix. This is a special, feature-like, branch which is merged directly into the testing branch (dont mind, it will also be merged into the experimental for later use)
In coldfixes you solve problems discovered while quality assurance.

Example:

    gitr variant linux-only
    gitr testing
    gitr init
    ...
    <test your code and find a bug in tcp layer>
    ...
    gitr coldfix tcp-layer
    ...
    <fix the bug>
    ...
    gitr upmerge

###Releasing the release ;)

Ok, your done with all coldfixes and would swear that everything is bugless.
Than you're ready to release! All you need to do is to merge your testing into the stable branch and tag it.

    gitr variant linux-only
    gitr stable
    gitr init
    git tag v1.0

###Dealing with bugs in releases

If you find (or get reported about) a bug in your current release you need to hotfix that. The procedure
is similar to coldfixing the testing branch:

    gitr variant linux-only
    gitr stable
    gitr hotfix tcp-layer
    ...
    <fix the bug>
    ...
    gitr upmerge
    gitr stable
    git tag v1.0.1

 