gitr - a branching model for multiple variants
==============================================

gitr let you manage multiple variants of your software, and makes it simple to
develop specific and (variant-) universal features.
It includes a staging from feature branch to experimental to stable, and also Hot- and Coldfix branches.

To start adding variants to your code simply init gitr by starting your universal variant and 
derive your other variants from it:

    gitr variant universal            #create special variant universal
    gitr variant platform-independend #create variant "platform-independend"
    gitr variant linux-only           #create another variant "linux-only"

The creation of a variant does basically two things

* create a experimental branch for this variant
* create a stable branch

To switch between variants use the same command as you used to create them.

Now checkout the variant you want to work on and start creating features:

    gitr variant linux-only
    gitr feature tcp-layer

The first command selects the variant you want to extend, the second creates a feature branch named "tcp-layer".
Now you can start commiting your feature using normal git commands, -> git add, git commit



