Colors = new Meteor.Collection 'colors'
Meteor.subscribe 'colors'
F = {}
T = Template
T.color_list.colors = -> Colors.find {}, sort: likes: -1, name: 1

_.Colors = Colors
_s = _.str
home_url = 'www.hi16.ca'
Router.configure layoutTemplate: 'layout'
Router.map -> 
    this.route 'home', path: '/'
    this.route 'about' 
    this.route 'help'
    this.route 'profile'
    this.route 'settings'
#window.onscroll = ( e ) -> scroll = window.scrollY * 3; console.log scroll; $('.box').attr('style', "-webkit-transform: rotateY(#{scroll}deg );") 
window.onresize = -> console.log window.innerWidth
T.__define__ 'help2', -> HTML.Raw '''
    <div class="col-sm-4">Help with define.</div>
    <div class="col-sm-8">Yes way.</div>
'''
T.color_list.events 'click button': -> Colors.update Session.get( 'session_color' ), $inc: likes: 1 
T.color_info.events 'click': -> Session.set 'session_color', this._id
T.color_info.maybe_selected = -> if Session.equals 'session_color', this._id then 'selected' else 'not_selected'
T.navbar.helpers
    instagram_connect: -> 'https://api.instagram.com/oauth/authorize/?' + _.queryString
        client_id: 'af97412ac5b94e18af85ced8d55785bd'
        redirect_uri: 'http://www.hi16.ca:3003/callback/instagram/'
        response_type: 'code'

toggleDropdown = -> $('#login-dropdown-list .dropdown-menu').dropdown('toggle')

signup = -> 
    __.resetMessages()
    options = {}
    username = trimmedElementValueById 'username'
    if username != null
        if !Accounts.loginButtons.validateUsername username
            return
        else
            options.username = username
    email = trimmedElementValueById 'email'
    if email != null
        if !Accounts.loginButtons.validateEmail email
            return
        else
            options.email = email
    password = elementValueById 'password'
    if !Accounts.loginButtons.validatePassword password
        return
    else
        options.password = password
    return if !matchPasswordAgainIfPresent()
    options.profile = {}
    errorFn = ( errorMessage ) -> __.errorMessage(errorMessage)
    invalidExtraSignupFields = false
    _.each Accounts.ui._options.extraSignupFields, ( field, index ) ->
        value = elementValueById field.fieldName
        if typeof field.validate == 'function'
            if field.validate value, errorFn
                options.profile[ field.fieldName ] = elementValueById field.fieldName
            else
                invalidExtraSignupFields = true
        else
            options.profile[ field.fieldName ] = elementValueById field.fieldName
    return if invalidExtraSignupFields
    Accounts.createUser options, ( error ) ->
        if error then __.errorMessage error.reason || "Unknown error" else __.closeDropdown()
forgotPassword = ->
    __.resetMessages()
    email = trimmedElementValueById "forgot-password-email"
    if email.indexOf('@') != -1
        Accounts.forgotPassword email: email, ( error ) -> 
            if error then __.errorMessage error.reason || "Unknown error" else __.infoMessage "Email sent"  
    else
        __.infoMessage "Email sent"
changePassword = ->
    __.resetMessages()
    oldPassword = elementValueById 'old-password'
    password = elementValueById 'password'
    return if !Accounts.loginButtons.validatePassword password || !matchPasswordAgainIfPresent()
    Accounts.changePassword oldPassword, password, ( error ) ->
        if error
            __.errorMessage error.reason || "Unknown error" 
        else 
            __.infoMessage "Password changed"
            Meteor.setTimeout( -> 
                __.resetMessages() 
                __.closeDropdown()
                $('#login-dropdown-list').removeClass 'open'
            , 3000 )
matchPasswordAgainIfPresent = ->
    passwordAgain = elementValueById 'password-again'
    if passwordAgain != null
        password = elementValueById 'password'
        if password != passwordAgain
            __.errorMessage "Passwords don't match"
            return false
    true

loginOrSignup = -> if __.get 'inSignupFlow' then signup() else login()

Accounts.ui.config passwordSignupFields: 'USERNAME_AND_EMAIL'
T.hello.events 'click input': -> console.log Router.current().route.name
T.home.rendered = ->
    container = $('#blue')
    _.each [1..20], (i) -> container.append( $("""<div id="tile-#{i}" class="tile box"><h2>Tile #{i}</h2></div>""") ) 
    $('.tile').on 'scrollSpy:enter', -> console.log 'enter:', $(this).attr 'id' 
    $('.tile').on 'scrollSpy:exit', -> console.log 'exit:', $(this).attr 'id' 
    $('.tile').scrollSpy()
    container.packery itemSelector: '.box', gutter: 1
        
vaild_keys = [
    'dropdownVisible', 'inSignupFlow', 'inForgotPasswordFlow', 'inChangePasswordFlow', 'inMessageOnlyFlow',
    'errorMessage', 'infoMessage', 'resetPasswordToken', 'enrollAccountToken', 'justVerifiedEmail',
    'configureLoginServiceDialogVisible', 'configureLoginServiceDialogServiceName', 'configureLoginServiceDialogSaveDisabled' ]
validateKey = ( key ) ->  throw new Error "Invalid key in loginButtonsSession: " + key if !_.contains vaild_keys, key
__ = Accounts.loginSession = Accounts.loginButtonsSession =
    set: ( key, value ) ->
        validateKey key
        if _.contains ['errorMessage', 'infoMessage'], key
            throw new Error "Don't set errorMessage or infoMessage directly. Instead, use errorMessage() or infoMessage()."
        this._set( key, value )      
    _set: ( key, value ) -> Session.set( "Meteor.loginButtons." + key, value)
    get: ( key ) -> validateKey key ; Session.get 'Meteor.loginButtons.' + key 
    closeDropdown: ->
        this.set 'inSignupFlow', false
        this.set 'inForgotPasswordFlow', false
        this.set 'inChangePasswordFlow', false
        this.set 'inMessageOnlyFlow', false
        this.set 'dropdownVisible', false
        this.resetMessages
    infoMessage: ( message ) ->
        this._set "errorMessage", null
        this._set "infoMessage", message
        this.ensureMessageVisible
    errorMessage: ( message ) ->
        this._set "errorMessage", message
        this._set "infoMessage", null
        this.ensureMessageVisible
    isMessageDialogVisible: -> this.get('resetPasswordToken') || this.get('enrollAccountToken') || this.get('justVerifiedEmail')
    ensureMessageVisible: -> this.set "dropdownVisible", true if !this.isMessageDialogVisible
    resetMessages: ->
        this._set "errorMessage", null
        this._set "infoMessage", null
    configureService: (name) -> 
        this.set 'configureLoginServiceDialogVisible', true
        this.set 'configureLoginServiceDialogServiceName', name
        this.set 'configureLoginServiceDialogSaveDisabled', true

Accounts.loginButtons = {} if !Accounts.loginButtons
Accounts.loginButtons.displayName = ->
    user = Meteor.user()
    if !user then '' 
    else if user.profile && user.profile.name then user.profile.name
    else if user.username then user.username
    else if user.emails && user.emails[0] && user.emails[0].address then user.emails[0].address  
    else ''
Accounts.loginButtons.getLoginServices = ->
    services = if Package['accounts-oauth'] then Accounts.oauth.serviceNames() else []
    services.sort()
    services.push 'password' if this.hasPasswordService()
    _.map services, ( name ) -> name: name
Accounts.loginButtons.hasPasswordService = -> !!Package['accounts-password']  
Accounts.loginButtons.dropdown = -> this.hasPasswordService() || Accounts.loginButtons.getLoginServices().length > 1
Accounts.loginButtons.validateUsername = ( username ) ->
    if username.length >= 3 then true else __.errorMessage "Username must be at least 3 characters long" && false
Accounts.loginButtons.validateEmail = ( email ) -> 
    return true if Accounts.ui._passwordSignupFields() == "USERNAME_AND_OPTIONAL_EMAIL" && email == ''
    re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
    if re.test email then true else __.errorMessage "Invalid email" && false
Accounts.loginButtons.validatePassword = ( password ) ->
    if password.length >= 6 then true else __.errorMessage "Password must be at least 6 characters long" &&  false
Accounts.loginButtons.rendered = -> debugger

_.each _.keys( _.define ), ( name ) ->
    _.each _.keys( _.define[ name ] ), ( key ) ->
        if ( key == 'helpers' )
            T[ name ].helpers( _.define[ name ].helpers )
        else if ( key == 'events' )
            T[ name ].events( _.define[ name ].events )
        else
            T[ name ][ key ] = _.define[ name ][ key ]


T.loginButtons.toggleDropdown = -> toggleDropdown()
T._loginButtonsMessages.helpers
    errorMessage: -> __.get 'errorMessage'
    infoMessage: -> __.get 'infoMessage'
T._loginButtonsLoggingInPadding.dropdown = -> Accounts.loginButtons.dropdown()

###########################################################################
T._loginButtonsLoggedOutSingleLoginButton.events
    'click .login-button': ->
        serviceName = this.name
        __.resetMessages()
        callback = ( err ) ->
            if !err
                __.closeDropdown()
            else if err instanceof Accounts.LoginCancelledError
                0
            else if err instanceof Accounts.ConfigError
                __.configureService serviceName
            else
                __.errorMessage err.reason || "Unknown error"
        loginWithService = Meteor[ "loginWith" + _s.capitalize serviceName ]
        options = {}
        if Accounts.ui._options.requestPermissions[ serviceName ]
            options.requestPermissions = Accounts.ui._options.requestPermissions[ serviceName ]
        loginWithService options, callback
T._loginButtonsLoggedOutSingleLoginButton.configured = -> !!Accounts.loginServiceConfiguration.findOne service: this.name
T._loginButtonsLoggedOutSingleLoginButton.capitalizedName = -> if this.name == 'github' then 'GitHub' else _s.capitalize this.name
###########################################################################

T._loginButtonsLoggedInDropdownActions.helpers
    allowChangingPassword: -> user = Meteor.user() ; user.username || ( user.emails && user.emails[0] && user.emails[0].address )
    additionalLoggedInDropdownActions: -> T._loginButtonsAdditionalLoggedInDropdownActions != undefined
T._loginButtonsLoggedOutDropdown.events
    'click #login-buttons-password': -> loginOrSignup()
    'keypress #forgot-password-email': ( event ) -> forgotPassword() if event.keyCode == 13
    'click #login-buttons-forgot-password': ( event ) -> event.stopPropagation() ; forgotPassword()
    'click #signup-link': ( event ) -> 
        event.stopPropagation()
        __.resetMessages()
        username = trimmedElementValueById 'username'
        email = trimmedElementValueById 'email'
        usernameOrEmail = trimmedElementValueById 'username-or-email'
        password = elementValueById 'password'
        __.set 'inSignupFlow', true
        __.set 'inForgotPasswordFlow', false
        Meteor.flush();
        if username != null
            document.getElementById('username').value = username
        else if email != null
            document.getElementById('email').value = email
        else if usernameOrEmail != null and usernameOrEmail.indexOf('@') == -1
            document.getElementById('username').value = usernameOrEmail
        else
            document.getElementById('email').value = usernameOrEmail
    'click #forgot-password-link': ( event ) ->
        event.stopPropagation()
        __.resetMessages()
        email = trimmedElementValueById 'email'
        usernameOrEmail = trimmedElementValueById 'username-or-email'
        __.set('inSignupFlow', false)
        __.set('inForgotPasswordFlow', true);
        Meteor.flush()
        if email != null
            document.getElementById('forgot-password-email').value = email
        else if usernameOrEmail != null
            if usernameOrEmail.indexOf('@') != -1
                document.getElementById('forgot-password-email').value = usernameOrEmail
    'click #back-to-login-link': ->
        __.resetMessages()
        username = trimmedElementValueById 'username'
        email = trimmedElementValueById('email') || trimmedElementValueById('forgot-password-email')
        __.set 'inSignupFlow', false
        __.set 'inForgotPasswordFlow', false
        Meteor.flush()
        document.getElementById('username').value = username if document.getElementById 'username'
        document.getElementById('email').value = email if document.getElementById 'email'
        document.getElementById('username-or-email').value = email || username if document.getElementById 'username-or-email'
    'keypress #username, keypress #email, keypress #username-or-email, keypress #password, keypress #password-again': ( event ) ->
        loginOrSignup() if event.keyCode == 13
T._loginButtonsLoggedOutDropdown.helpers
    additionalClasses: ->
        if !Accounts.password then false
        else if __.get 'inSignupFlow' then 'login-form-create-account'
        else if __.get 'inForgotPasswordFlow' then 'login-form-forgot-password'
        else 'login-form-sign-in'
    dropdownVisible: -> __.get 'dropdownVisible'
    hasPasswordService: -> Accounts.loginButtons.hasPasswordService()
    forbidClientAccountCreation: -> Accounts._options.forbidClientAccountCreation # useless
T._loginButtonsLoggedOutAllServices.helpers
    services: -> Accounts.loginButtons.getLoginServices()
    isPasswordService: -> this.name == 'password'
    hasOtherServices: -> Accounts.loginButtons.getLoginServices().length > 1
    hasPasswordService: -> Accounts.loginButtons.hasPasswordService()

T.formField.helpers
    type: -> this.type or "text"
    visible: -> if this.visible == undefined then true else if typeof this.visible == 'function' then this.visible() else this.visible
    name: -> this.name or _s.dasherize _s.trim this.label.toLowerCase()
    title: -> this.title
T._loginButtonsChangePassword.events
    'keypress #old-password, keypress #password, keypress #password-again': ( event ) -> changePassword() if event.keyCode == 13
    'click #login-buttons-do-change-password': ( event ) -> event.stopPropagation(); changePassword()
    'click #login-buttons-back-to-menu': ( event ) -> event.stopPropagation(); $('#login-dropdown-list').removeClass 'open'
T._loginButtonsChangePassword.fields = -> [
    name: 'old-password'
    label: 'Current Password', icon: 'key',           type: 'password'
,
    name: 'password'
    label: 'New Password',     icon: 'asterisk',      type: 'password'
,
    name: 'password-again'
    label: 'New Password (again)',                    type: 'password',           visible: -> 
        _.contains( ["USERNAME_AND_OPTIONAL_EMAIL", "USERNAME_ONLY"], Accounts.ui._passwordSignupFields() ) ]
elementValueById = ( id ) ->
    element = document.getElementById( id )
    if element then element.value else null
trimmedElementValueById = ( id ) ->
    element = document.getElementById( id )
    if element then element.value.replace(/^\s*|\s*$/g, "") else null
login = -> 
    __.resetMessages()
    username = trimmedElementValueById 'username'
    email = trimmedElementValueById 'email'
    usernameOrEmail = trimmedElementValueById 'username-or-email'
    password = elementValueById 'password'
    loginSelector = undefined
    if username != null
        if !Accounts.loginButtons.validateUsername username
            return
        else
            loginSelector = username: username
    else if email != null
        if !Accounts.loginButtons.validateEmail email
            return
        else
            loginSelector = email: email
    else if usernameOrEmail != null
        if !Accounts.loginButtons.validateUsername usernameOrEmail
            return
        else
            loginSelector = usernameOrEmail
    else
        throw new Error "Unexpected -- no element to use as a login user selector"
    Meteor.loginWithPassword loginSelector, password, ( error, result ) -> 
        if error then __.errorMessage( error.reason || "Unknown error" ) else __.closeDropdown()
__.set 'resetPasswordToken', Accounts._resetPasswordToken if Accounts._resetPasswordToken
__.set 'enrollAccountToken', Accounts._enrollAccountToken if Accounts._enrollAccountToken
Meteor.startup ->
    if Accounts._verifyEmailToken
        Accounts.verifyEmail Accounts._verifyEmailToken, ( error ) ->
            Accounts._enableAutoLogin()
            __.set 'justVerifiedEmail', true if !error

T._resetPasswordDialog.rendered = ->
    $modal = $(this.find '#login-buttons-reset-password-modal' )
    $modal.modal()
T._resetPasswordDialog.events
    'click #login-buttons-reset-password-button': -> resetPassword()
    'keypress #reset-password-new-password': ( event ) -> resetPassword() if event.keyCode == 13
    'click #login-buttons-cancel-reset-password': ->
        __.set 'resetPasswordToken', null
        Accounts._enableAutoLogin()
        $('#login-buttons-reset-password-modal').modal 'hide'
resetPassword = ->
    __.resetMessages()
    newPassword = document.getElementById('reset-password-new-password').value
    return if !Accounts.loginButtons.validatePassword newPassword
    Accounts.resetPassword __.get('resetPasswordToken'), newPassword, ( error ) ->
        if error
            __.errorMessage error.reason || "Unknown error"
        else
            __.set 'resetPasswordToken', null
            Accounts._enableAutoLogin()
            $('#login-buttons-reset-password-modal').modal "hide"
T._resetPasswordDialog.inResetPasswordFlow = -> __.get('resetPasswordToken')
T._enrollAccountDialog.events
    'click #login-buttons-enroll-account-button': -> enrollAccount()
    'keypress #enroll-account-password': ( event ) -> enrollAccount() if event.keyCode == 13
    'click #login-buttons-cancel-enroll-account-button': ->
        __.set 'enrollAccountToken', null
        Accounts._enableAutoLogin()
        $modal.modal "hide"
T._enrollAccountDialog.rendered = ->
    $modal = $(this.find '#login-buttons-enroll-account-modal' )
    $modal.modal()
enrollAccount = ->
    __.resetMessages()
    password = document.getElementById('enroll-account-password').value
    return if !Accounts.loginButtons.validatePassword password
    Accounts.resetPassword __.get('enrollAccountToken'), password, ( error ) ->
        if error
            __.errorMessage error.reason || "Unknown error"
        else
            __.set 'enrollAccountToken', null
            Accounts._enableAutoLogin()
            $modal.modal "hide"
T._enrollAccountDialog.inEnrollAccountFlow = -> __.get('enrollAccountToken')
T._justVerifiedEmailDialog.events 'click #just-verified-dismiss-button': -> __.set('justVerifiedEmail', false)
T._justVerifiedEmailDialog.visible = -> __.get('justVerifiedEmail')
T._loginButtonsMessagesDialog.events 'click #messages-dialog-dismiss-button': -> __.resetMessages()
T._loginButtonsMessagesDialog.visible = -> !Accounts.loginButtons.dropdown() && ( __.get('infoMessage') || __.get('errorMessage') )
T._configureLoginServiceDialog.events
    'input, keyup input': ( event ) -> updateSaveDisabled() if event.target.id.indexOf 'configure-login-service-dialog' == 0
    'click .configure-login-service-dismiss-button': -> __.set 'configureLoginServiceDialogVisible', false
    'click #configure-login-service-dialog-save-configuration': ->
        if __.get('configureLoginServiceDialogVisible') && !__.get('configureLoginServiceDialogSaveDisabled')
            serviceName = __.get('configureLoginServiceDialogServiceName')
            configuration = service: serviceName
            _.each configurationFields(), ( field ) ->
                configuration[ field.property ] = document.getElementById(
                    'configure-login-service-dialog-' + field.property ).value.replace(/^\s*|\s*$/g, "")
            Meteor.call 'configureLoginService', configuration, ( error, result ) ->
                if error
                    Meteor._debug 'Error configuring login service ' + serviceName, error
                else
                    __.set 'configureLoginServiceDialogVisible', false
updateSaveDisabled = ->
    anyFieldEmpty = _.any(configurationFields(), ( field ) -> 
        document.getElementById( 'configure-login-service-dialog-' + field.property).value == '' )
    __.set 'configureLoginServiceDialogSaveDisabled', anyFieldEmpty
configureLoginServiceDialogTemplateForService = ->
    serviceName = __.get 'configureLoginServiceDialogServiceName'
    Template[ 'configureLoginServiceDialogFor' + _s.capitalize serviceName ]
configurationFields = ->
    template = configureLoginServiceDialogTemplateForService()
    template.fields()
T._configureLoginServiceDialog.helpers
    configurationFields: -> configurationFields()
    visible: -> __.get 'configureLoginServiceDialogVisible'
    configurationSteps: -> configureLoginServiceDialogTemplateForService()()
    saveDisabled: -> __.get 'configureLoginServiceDialogSaveDisabled'
