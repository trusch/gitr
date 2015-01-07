#compdef gitr

_arguments '1: :->action' '2: :->specifier'
case $state in
    action)
        _arguments -s ':actions:(variant experimental testing stable feature hotfix coldfix variants features hotfixs coldfixs upmerge update init)';;
    *)
        case $words[2] in
            variant)
                compadd "$@" $(gitr variants)
            ;;
            feature)
                compadd "$@" $(gitr features)
            ;;
            hotfix)
                compadd "$@" $(gitr hotfixes)
            ;;
            coldfix)
                compadd "$@" $(gitr coldfixes)
            ;;
        esac
esac

