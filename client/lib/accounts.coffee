Accounts.ui = {} if !Accounts.ui
Accounts.ui._options = requestPermissions: {}, extraSignupFields: [] if !Accounts.ui._options
Accounts.ui.navigate = ( route, hash ) -> Router.go route, hash
Accounts.ui.config = ( options ) ->
    _.each _.keys( options ), ( key ) ->
        if !_.contains ['passwordSignupFields', 'requestPermissions', 'extraSignupFields'], key
            throw new Error "Accounts.ui.config: Invalid key: " + key 
    if options.passwordSignupFields
        if _.contains [
            'USERNAME_AND_EMAIL_CONFIRM'
            'USERNAME_AND_EMAIL'
            'USERNAME_AND_OPTIONAL_EMAIL'
            'USERNAME_ONLY'
            'EMAIL_ONLY'
        ], options.passwordSignupFields
            if Accounts.ui._options.passwordSignupFields
                throw new Error "Accounts.ui.config: Can't set `passwordSignupFields` more than once"
            else
                Accounts.ui._options.passwordSignupFields = options.passwordSignupFields
        else
            throw new Error 'Accounts.ui.config: Invalid option for `passwordSignupFields`: ' + options.passwordSignupFields

    if options.requestPermissions
        _.each options.requestPermissions, ( scope, service ) ->
            if Accounts.ui._options.requestPermissions[ service ]
                throw new Error "Accounts.ui.config: Can't set `requestPermissions` more than once for " + service
            else if !(scope instanceof Array)
                throw new Error 'Accounts.ui.config: Value for `requestPermissions` must be an array'
            else
                Accounts.ui._options.requestPermissions[ service ] = scope
        if typeof options.extraSignupFields != 'object' || !options.extraSignupFields instanceof Array
            throw new Error 'Accounts.ui.config: `extraSignupFields` must be an array.'
        else
            if options.extraSignupFields
                _.each options.extraSignupFields, ( field, index ) ->
                    if !field.fieldName || !field.fieldLabel
                        throw new Error 'Accounts.ui.config: `extraSignupFields` objects must have `fieldName` and `fieldLabel` attributes.'
                    if typeof field.visible == 'undefined'
                        field.visible = true
                    Accounts.ui._options.extraSignupFields[ index ] = field

Accounts.ui._passwordSignupFields = -> Accounts.ui._options.passwordSignupFields || 'EMAIL_ONLY'
