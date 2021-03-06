gitr - a branching model for multiple variants
==============================================

gitr let you manage multiple variants of your software, and makes it simple to
develop specific and (variant-) universal features.
It includes a staging from feature branch to experimental to testing to stable, and also Hot- and Coldfix branches.

##Getting started
###Creating Variants
To start adding your first variants to your code simply init gitr by starting your universal variant and 
derive your other variants from it:

    gitr variant universal            # create special variant universal
    gitr variant platform-independend # create variant "platform-independend"
    gitr variant linux-only           # create another variant "linux-only"

The creation of a variant does basically three things

* create a experimental branch for this variant
* create a testing branch
* create a stable branch

To switch between variants use the same command as you used to create them.

###Creating Features

Now checkout the variant you want to work on and start creating features:

    gitr variant linux-only    # select variant linux-only
    gitr feature tcp-layer     # create feature tcp-layer on current variant

The first command selects the variant you want to extend, the second creates a feature branch named "tcp-layer".
Now you can start commiting your feature using normal git commands, -> git add, git commit

###Upmerge to experimental and keep your feature up to date

While your daily work, you should regulary fetch changes from the experimental branch.
To do so, you can use the "gitr update" command. This command updates the currently active branch.
So if you are on a feature branch "gitr update" will merge the experimental branch of the active variant into your feature.
If you are done with your feature, upmerge it into experimental. Therefore "gitr upmerge" is available.

Example:
    
    gitr variant linux-only    # select variant linux-only
    gitr feature tcp-layer     # checkout feature tcp-layer
    ...
    git add src/TCPLayer.h
    git commit -m "added tcp layer header"
    ...
    gitr update                # merge experimental into current feature
    ...
    git add src/TCPLayer.cpp
    git commit -m "added tcp layer implementation"
    ...
    gitr upmerge               # merges the feature into experimental


###Preparing a release

If you're fine with your features, it's time for the testing and correction phase before releasing it.
To do so, you upmerge your experimental to the testing branch and perform all your code tests on it. If you find some issues its time for a coldfix. This is a special, feature-like, branch which is merged directly into the testing branch (dont mind, it will also be merged into the experimental for later use)
In coldfixes you solve problems discovered while quality assurance.

Example:

    gitr variant linux-only    # select variant linux-only
    gitr testing               # checkout testing branch
    gitr init                  # merge experimental into testing
    ...
    <test your code and find a bug in tcp layer>
    ...
    gitr coldfix tcp-layer     # checkout coldfix tcp-layer
    ...
    <fix the bug>
    ...
    gitr upmerge               # merge coldfix into testing

###Releasing the release ;)

Ok, your done with all coldfixes and would swear that everything is bugless.
Than you're ready to release! All you need to do is to merge your testing into the stable branch and tag it.

    gitr variant linux-only    # select variant linux-only
    gitr stable                # checkout stable branch
    gitr init                  # merge testing into stable
    git tag v1.0               # tag the release

###Dealing with bugs in releases

If you find (or get reported about) a bug in your current release you need to hotfix that. The procedure
is similar to coldfixing the testing branch:

    gitr variant linux-only   # select variant linux-only
    gitr stable               # checkout stable branch
    gitr hotfix tcp-layer     # checkout hotfix tcp-layer
    ...
    <fix the bug>
    ...
    gitr upmerge              # merge hotfix into stable
    gitr stable               # checkout stable branch
    git tag v1.0.1            # tag the hotfix-release

##Working with variants

###The universal variant

As you probably noticed in the examples above the first command "gitr variant <variantname>" 
selects which variant you want to work on. If you want to make changes to all your variants
select the special variant "universal"
If you are upmerging a feature branch from universal it is additionally merged into all other experimental branches,
so it will be available in all your variants.

Example:

    gitr variant universal    # select special variant universal
    gitr feature f1           # create universal feature f1
    ...
    <commit to the feature>
    ...
    gitr upmerge              # upmerge the feature to all experimental branches

###Universal Hot- and Coldfixes

Universal Hot- and Coldfixes are special. Due to the fact, that some universal features 
could not allready be merged up into all testing or stable branches, you must merge these fixes by hand.

Example:
    
    gitr variant universal    # select special variant universal
    gitr testing              # checkout testing branch
    gitr coldfix c1           # create universal coldfix c1
    ...
    <commit to the coldfix>
    ...
    gitr upmerge                        # upmerge the feature to all experimental(!) branches
    gitr variant linux-only             # select the variant where the coldfix makes sense
    gitr testing                        # checkout testing branch
    git merge gitr/universal/coldfix/c1 # manually merge the coldfix


##Other goodies

There are some other goodies in gitr which will make your life easier.

###gitr ls

The command "gitr ls" will output a tree-like representation of all your gitr branches.
It will also mark your current branch with an asterix.

Example:

    gitr ls
      universal/
          experimental
          testing
          stable
          feature/
              foo
      var1/
    *     experimental
          testing
          stable
      var2/
          experimental
          testing
          stable
          coldfix/
              c1
              c2

###gitr variants|features|coldfixes|hotfixes

This will print all variants, repectively all features/coldfixes/hotfixes of the active variant

###gitr rm <variant/(feature|coldfix|hotfix)/specifier>

This will delete the selected branch

Example:

    gitr ls
      universal/
          experimental
          testing
          stable
          feature/
              foo
      var1/
    *     experimental
          testing
          stable
      var2/
          experimental
          testing
          stable
          coldfix/
              c1
              c2
    
    gitr rm var2/coldfix/c2    # delete branch
    
    gitr ls
      universal/
          experimental
          testing
          stable
          feature/
              foo
      var1/
    *     experimental
          testing
          stable
      var2/
          experimental
          testing
          stable
          coldfix/
              c1
    
    