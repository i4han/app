(function () {
  var VALID_KEYS = [
    'dropdownVisible',

    // XXX consider replacing these with one key that has an enum for values.
    'inSignupFlow',
    'inForgotPasswordFlow',
    'inChangePasswordFlow',
    'inMessageOnlyFlow',

    'errorMessage',
    'infoMessage',

    // dialogs with messages (info and error)
    'resetPasswordToken',
    'enrollAccountToken',
    'justVerifiedEmail',

    'configureLoginServiceDialogVisible',
    'configureLoginServiceDialogServiceName',
    'configureLoginServiceDialogSaveDisabled'
  ];

  var validateKey = function (key) {
    if (!_.contains(VALID_KEYS, key))
      throw new Error("Invalid key in loginButtonsSession: " + key);
  };

  var KEY_PREFIX = "Meteor.loginButtons.";

  // XXX we should have a better pattern for code private to a package like this one
  Accounts._loginButtonsSession = {
    set: function(key, value) {
      validateKey(key);
      if (_.contains(['errorMessage', 'infoMessage'], key))
        throw new Error("Don't set errorMessage or infoMessage directly. Instead, use errorMessage() or infoMessage().");

      this._set(key, value);
    },

    _set: function(key, value) {
      Session.set(KEY_PREFIX + key, value);
    },

    get: function(key) {
      validateKey(key);
      return Session.get(KEY_PREFIX + key);
    },

    closeDropdown: function () {
      this.set('inSignupFlow', false);
      this.set('inForgotPasswordFlow', false);
      this.set('inChangePasswordFlow', false);
      this.set('inMessageOnlyFlow', false);
      this.set('dropdownVisible', false);
      this.resetMessages();
    },

    infoMessage: function(message) {
      this._set("errorMessage", null);
      this._set("infoMessage", message);
      this.ensureMessageVisible();
    },

    errorMessage: function(message) {
      this._set("errorMessage", message);
      this._set("infoMessage", null);
      this.ensureMessageVisible();
    },

    // is there a visible dialog that shows messages (info and error)
    isMessageDialogVisible: function () {
      return this.get('resetPasswordToken') ||
        this.get('enrollAccountToken') ||
        this.get('justVerifiedEmail');
    },

    // ensure that somethings displaying a message (info or error) is
    // visible.  if a dialog with messages is open, do nothing;
    // otherwise open the dropdown.
    //
    // notably this doesn't matter when only displaying a single login
    // button since then we have an explicit message dialog
    // (_loginButtonsMessageDialog), and dropdownVisible is ignored in
    // this case.
    ensureMessageVisible: function () {
      if (!this.isMessageDialogVisible())
        this.set("dropdownVisible", true);
    },

    resetMessages: function () {
      this._set("errorMessage", null);
      this._set("infoMessage", null);
    },

    configureService: function (name) {
      this.set('configureLoginServiceDialogVisible', true);
      this.set('configureLoginServiceDialogServiceName', name);
      this.set('configureLoginServiceDialogSaveDisabled', true);
    }
  };
}) ();

(function() {
    if (!Accounts._loginButtons)
        Accounts._loginButtons = {};

    // for convenience
    var loginButtonsSession = Accounts._loginButtonsSession;

    Handlebars.registerHelper(
        "loginButtons",
        function(options) {
            if (options.hash.align === "left")
                return new Handlebars.SafeString(Template._loginButtons({
                    align: "left"
                }));
            else
                return new Handlebars.SafeString(Template._loginButtons({
                    align: "right"
                }));
        });

    // shared between dropdown and single mode
    Template._loginButtons.events({
        'click #login-buttons-logout': function() {
            Meteor.logout(function() {
                loginButtonsSession.closeDropdown();
                Accounts.ui.navigate("/");
            });
        },
        'click #login-buttons-profile': function() {
            $('#login-dropdown-list').removeClass('open');
            Router.go('profile');
        },
        'click #login-buttons-settings': function() {
            $('#login-dropdown-list').removeClass('open');
            Router.go('settings');
        }
    });

    Template._loginButtons.preserve({
        'input[id]': Spark._labelFromIdOrName
    });

    //
    // loginButtonLoggedOut template
    //

    Template._loginButtonsLoggedOut.dropdown = function() {
        return Accounts._loginButtons.dropdown();
    };

    Template._loginButtonsLoggedOut.services = function() {
        return Accounts._loginButtons.getLoginServices();
    };

    Template._loginButtonsLoggedOut.singleService = function() {
        var services = Accounts._loginButtons.getLoginServices();
        if (services.length !== 1)
            throw new Error(
                "Shouldn't be rendering this template with more than one configured service");
        return services[0];
    };

    Template._loginButtonsLoggedOut.configurationLoaded = function() {
        return Accounts.loginServicesConfigured();
    };


    //
    // loginButtonsLoggedIn template
    //

    // decide whether we should show a dropdown rather than a row of
    // buttons
    Template._loginButtonsLoggedIn.dropdown = function() {
        return Accounts._loginButtons.dropdown();
    };

    Template._loginButtonsLoggedIn.displayName = function() {
        return Accounts._loginButtons.displayName();
    };



    //
    // loginButtonsMessage template
    //

    Template._loginButtonsMessages.errorMessage = function() {
        return loginButtonsSession.get('errorMessage');
    };

    Template._loginButtonsMessages.infoMessage = function() {
        return loginButtonsSession.get('infoMessage');
    };

    //
    // loginButtonsLoggingInPadding template
    //

    Template._loginButtonsLoggingInPadding.dropdown = function() {
        return Accounts._loginButtons.dropdown();
    };

    //
    // helpers
    //

    Accounts._loginButtons.displayName = function() {
        var user = Meteor.user();
        if (!user)
            return 'Sign';

        if (user.profile && user.profile.name)
            return user.profile.name;
        if (user.username)
            return user.username;
        if (user.emails && user.emails[0] && user.emails[0].address)
            return user.emails[0].address;

        return 'Sign';
    };

    Accounts._loginButtons.getLoginServices = function() {
        // First look for OAuth services.
        var services = Package['accounts-oauth'] ? Accounts.oauth.serviceNames() : [];

        // Be equally kind to all login services. This also preserves
        // backwards-compatibility. (But maybe order should be
        // configurable?)
        services.sort();

        // Add password, if it's there; it must come last.
        if (this.hasPasswordService())
            services.push('password');

        return _.map(services, function(name) {
            return {
                name: name
            };
        });
    };

    Accounts._loginButtons.hasPasswordService = function() {
        return !!Package['accounts-password'];
    };

    Accounts._loginButtons.dropdown = function() {
        return this.hasPasswordService() || Accounts._loginButtons.getLoginServices().length > 1;
    };

    // XXX improve these. should this be in accounts-password instead?
    //
    // XXX these will become configurable, and will be validated on
    // the server as well.
    Accounts._loginButtons.validateUsername = function(username) {
        if (username.length >= 3) {
            return true;
        } else {
            loginButtonsSession.errorMessage("Username must be at least 3 characters long");
            return false;
        }
    };
    Accounts._loginButtons.validateEmail = function(email) {
        if (Accounts.ui._passwordSignupFields() === "USERNAME_AND_OPTIONAL_EMAIL" && email === '')
            return true;

        var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;

        if (re.test(email)) {
            return true;
        } else {
            loginButtonsSession.errorMessage("Invalid email");
            return false;
        }
    };
    Accounts._loginButtons.validatePassword = function(password) {
        if (password.length >= 6) {
            return true;
        } else {
            loginButtonsSession.errorMessage("Password must be at least 6 characters long");
            return false;
        }
    };

    Accounts._loginButtons.rendered = function () {
        debugger;
    };

})();

(function () {
  // for convenience
  var loginButtonsSession = Accounts._loginButtonsSession;

  Template._loginButtonsLoggedOutSingleLoginButton.events({
    'click .login-button': function () {
      var serviceName = this.name;
      loginButtonsSession.resetMessages();
      var callback = function (err) {
        if (!err) {
          loginButtonsSession.closeDropdown();
        } else if (err instanceof Accounts.LoginCancelledError) {
          // do nothing
        } else if (err instanceof Accounts.ConfigError) {
          loginButtonsSession.configureService(serviceName);
        } else {
          loginButtonsSession.errorMessage(err.reason || "Unknown error");
        }
      };

      var loginWithService = Meteor["loginWith" + capitalize(serviceName)];

      var options = {}; // use default scope unless specified
      if (Accounts.ui._options.requestPermissions[serviceName])
        options.requestPermissions = Accounts.ui._options.requestPermissions[serviceName];

      loginWithService(options, callback);
    }
  });

  Template._loginButtonsLoggedOutSingleLoginButton.configured = function () {
    return !!Accounts.loginServiceConfiguration.findOne({service: this.name});
  };

  Template._loginButtonsLoggedOutSingleLoginButton.capitalizedName = function () {
    if (this.name === 'github')
      // XXX we should allow service packages to set their capitalized name
      return 'GitHub';
    else
      return capitalize(this.name);
  };

  // XXX from http://epeli.github.com/underscore.string/lib/underscore.string.js
  var capitalize = function(str){
    str = str == null ? '' : String(str);
    return str.charAt(0).toUpperCase() + str.slice(1);
  };
}) ();

(function() {

    // for convenience
    var loginButtonsSession = Accounts._loginButtonsSession;

    // events shared between loginButtonsLoggedOutDropdown and
    // loginButtonsLoggedInDropdown
    Template._loginButtons.events({
        'click input, click label, click button, click .dropdown-menu, click .alert': function(event) {
            event.stopPropagation();
        },
        'click #login-name-link, click #login-sign-in-link': function() {
            event.stopPropagation();
            loginButtonsSession.set('dropdownVisible', true);
            Meteor.flush();
        },
        'click .login-close': function() {
            loginButtonsSession.closeDropdown();
        }
    });

    Template._loginButtons.toggleDropdown = function() {
      toggleDropdown();
    };

    //
    // loginButtonsLoggedInDropdown template and related
    //
 
    Template._loginButtonsLoggedInDropdown.events({
        'click #login-buttons-change-password': function(event) {
            event.stopPropagation();
            loginButtonsSession.resetMessages();
            loginButtonsSession.set('inChangePasswordFlow', true);
            Meteor.flush();
            toggleDropdown();
        }
    });

    Template._loginButtonsLoggedInDropdown.displayName = function() {
        return Accounts._loginButtons.displayName();
    };

    Template._loginButtonsLoggedInDropdown.inChangePasswordFlow = function() {
        return loginButtonsSession.get('inChangePasswordFlow');
    };

    Template._loginButtonsLoggedInDropdown.inMessageOnlyFlow = function() {
        return loginButtonsSession.get('inMessageOnlyFlow');
    };

    Template._loginButtonsLoggedInDropdown.dropdownVisible = function() {
        return loginButtonsSession.get('dropdownVisible');
    };

    Template._loginButtonsLoggedInDropdownActions.allowChangingPassword = function() {
        // it would be more correct to check whether the user has a password set,
        // but in order to do that we'd have to send more data down to the client,
        // and it'd be preferable not to send down the entire service.password document.
        //
        // instead we use the heuristic: if the user has a username or email set.
        var user = Meteor.user();
        return user.username || (user.emails && user.emails[0] && user.emails[0].address);
    };


    Template._loginButtonsLoggedInDropdownActions.additionalLoggedInDropdownActions = function () {
      return Template._loginButtonsAdditionalLoggedInDropdownActions !== undefined;
    };

    //
    // loginButtonsLoggedOutDropdown template and related
    //

    Template._loginButtonsLoggedOutDropdown.events({
        'click #login-buttons-password': function() {
            loginOrSignup();
        },

        'keypress #forgot-password-email': function(event) {
            if (event.keyCode === 13)
                forgotPassword();
        },

        'click #login-buttons-forgot-password': function(event) {
            event.stopPropagation();
            forgotPassword();
        },

        'click #signup-link': function(event) {
            event.stopPropagation();
            loginButtonsSession.resetMessages();

            // store values of fields before swtiching to the signup form
            var username = trimmedElementValueById('login-username');
            var email = trimmedElementValueById('login-email');
            var usernameOrEmail = trimmedElementValueById('login-username-or-email');
            // notably not trimmed. a password could (?) start or end with a space
            var password = elementValueById('login-password');

            loginButtonsSession.set('inSignupFlow', true);
            loginButtonsSession.set('inForgotPasswordFlow', false);

            // force the ui to update so that we have the approprate fields to fill in
            Meteor.flush();

            // update new fields with appropriate defaults
            if (username !== null)
                document.getElementById('login-username').value = username;
            else if (email !== null)
                document.getElementById('login-email').value = email;
            else if (usernameOrEmail !== null)
                if (usernameOrEmail.indexOf('@') === -1)
                    document.getElementById('login-username').value = usernameOrEmail;
                else
                    document.getElementById('login-email').value = usernameOrEmail;
        },
        'click #forgot-password-link': function(event) {
            event.stopPropagation();
            loginButtonsSession.resetMessages();

            // store values of fields before swtiching to the signup form
            var email = trimmedElementValueById('login-email');
            var usernameOrEmail = trimmedElementValueById('login-username-or-email');

            loginButtonsSession.set('inSignupFlow', false);
            loginButtonsSession.set('inForgotPasswordFlow', true);

            // force the ui to update so that we have the approprate fields to fill in
            Meteor.flush();
            //toggleDropdown();

            // update new fields with appropriate defaults
            if (email !== null)
                document.getElementById('forgot-password-email').value = email;
            else if (usernameOrEmail !== null)
                if (usernameOrEmail.indexOf('@') !== -1)
                    document.getElementById('forgot-password-email').value = usernameOrEmail;
        },
        'click #back-to-login-link': function() {
            loginButtonsSession.resetMessages();

            var username = trimmedElementValueById('login-username');
            var email = trimmedElementValueById('login-email') || trimmedElementValueById('forgot-password-email'); // Ughh. Standardize on names?

            loginButtonsSession.set('inSignupFlow', false);
            loginButtonsSession.set('inForgotPasswordFlow', false);

            // force the ui to update so that we have the approprate fields to fill in
            Meteor.flush();

            if (document.getElementById('login-username'))
                document.getElementById('login-username').value = username;
            if (document.getElementById('login-email'))
                document.getElementById('login-email').value = email;
            // "login-password" is preserved thanks to the preserve-inputs package
            if (document.getElementById('login-username-or-email'))
                document.getElementById('login-username-or-email').value = email || username;
        },
        'keypress #login-username, keypress #login-email, keypress #login-username-or-email, keypress #login-password, keypress #login-password-again': function(event) {
            if (event.keyCode === 13)
                loginOrSignup();
        }
    });

    // additional classes that can be helpful in styling the dropdown
    Template._loginButtonsLoggedOutDropdown.additionalClasses = function() {
        if (!Accounts.password) {
            return false;
        } else {
            if (loginButtonsSession.get('inSignupFlow')) {
                return 'login-form-create-account';
            } else if (loginButtonsSession.get('inForgotPasswordFlow')) {
                return 'login-form-forgot-password';
            } else {
                return 'login-form-sign-in';
            }
        }
    };

    Template._loginButtonsLoggedOutDropdown.dropdownVisible = function() {
        return loginButtonsSession.get('dropdownVisible');
    };

    Template._loginButtonsLoggedOutDropdown.hasPasswordService = function() {
        return Accounts._loginButtons.hasPasswordService();
    };

    Template._loginButtonsLoggedOutDropdown.forbidClientAccountCreation = function() {
        return Accounts._options.forbidClientAccountCreation;
    };

    Template._loginButtonsLoggedOutAllServices.services = function() {
        return Accounts._loginButtons.getLoginServices();
    };

    Template._loginButtonsLoggedOutAllServices.isPasswordService = function() {
        return this.name === 'password';
    };

    Template._loginButtonsLoggedOutAllServices.hasOtherServices = function() {
        return Accounts._loginButtons.getLoginServices().length > 1;
    };

    Template._loginButtonsLoggedOutAllServices.hasPasswordService = function() {
        return Accounts._loginButtons.hasPasswordService();
    };

    Template._loginButtonsLoggedOutPasswordService.fields = function() {
        var loginFields = [{
            fieldName: 'username-or-email',
            fieldLabel: 'Username or email',
            fieldIcon: 'user',
            visible: function() {
                return _.contains(
                    ["USERNAME_AND_EMAIL_CONFIRM", "USERNAME_AND_EMAIL", "USERNAME_AND_OPTIONAL_EMAIL"],
                    Accounts.ui._passwordSignupFields());
            }
        }, {
            fieldName: 'username',
            fieldLabel: 'Username',
            fieldIcon: 'user',
            visible: function() {
                return Accounts.ui._passwordSignupFields() === "USERNAME_ONLY";
            }
        }, {
            fieldName: 'email',
            fieldLabel: 'Email',
            fieldIcon: 'envelope-o',
            inputType: 'email',
            visible: function() {
                return Accounts.ui._passwordSignupFields() === "EMAIL_ONLY";
            }
        }, {
            fieldName: 'password',
            fieldLabel: 'Password',
            fieldIcon: 'key',
            inputType: 'password',
            visible: function() {
                return true;
            }
        }];

        var signupFields = [{
            fieldName: 'username',
            fieldLabel: 'Username',
            fieldIcon: 'user',

            visible: function() {
                return _.contains(
                    ["USERNAME_AND_EMAIL_CONFIRM", "USERNAME_AND_EMAIL", "USERNAME_AND_OPTIONAL_EMAIL", "USERNAME_ONLY"],
                    Accounts.ui._passwordSignupFields());
            }
        }, {
            fieldName: 'email',
            fieldLabel: 'Email',
            fieldIcon: 'envelope-o',
            inputType: 'email',
            visible: function() {
                return _.contains(
                    ["USERNAME_AND_EMAIL_CONFIRM", "USERNAME_AND_EMAIL", "EMAIL_ONLY"],
                    Accounts.ui._passwordSignupFields());
            }
        }, {
            fieldName: 'email',
            fieldLabel: 'Email (optional)',
            fieldIcon: 'envelope-o',
            inputType: 'email',
            visible: function() {
                return Accounts.ui._passwordSignupFields() === "USERNAME_AND_OPTIONAL_EMAIL";
            }
        }, {
            fieldName: 'password',
            fieldLabel: 'Password',
            fieldIcon: 'key',

            inputType: 'password',
            visible: function() {
                return true;
            }
        }, {
            fieldName: 'password-again',
            fieldLabel: 'Password (again)',
            fieldIcon: 'key',
            inputType: 'password',
            visible: function() {
                // No need to make users double-enter their password if
                // they'll necessarily have an email set, since they can use
                // the "forgot password" flow.
                return _.contains(
                    ["USERNAME_AND_EMAIL_CONFIRM", "USERNAME_AND_OPTIONAL_EMAIL", "USERNAME_ONLY"],
                    Accounts.ui._passwordSignupFields());
            }
        }];

        signupFields = Accounts.ui._options.extraSignupFields.concat(signupFields);

        return loginButtonsSession.get('inSignupFlow') ? signupFields : loginFields;
    };

    Template._loginButtonsLoggedOutPasswordService.inForgotPasswordFlow = function() {
        return loginButtonsSession.get('inForgotPasswordFlow');
    };

    Template._loginButtonsLoggedOutPasswordService.inLoginFlow = function() {
        return !loginButtonsSession.get('inSignupFlow') && !loginButtonsSession.get('inForgotPasswordFlow');
    };

    Template._loginButtonsLoggedOutPasswordService.inSignupFlow = function() {
        return loginButtonsSession.get('inSignupFlow');
    };

    Template._loginButtonsLoggedOutPasswordService.showForgotPasswordLink = function() {
        return _.contains(
            ["USERNAME_AND_EMAIL_CONFIRM", "USERNAME_AND_EMAIL", "USERNAME_AND_OPTIONAL_EMAIL", "EMAIL_ONLY"],
            Accounts.ui._passwordSignupFields());
    };

    Template._loginButtonsLoggedOutPasswordService.showCreateAccountLink = function() {
        return !Accounts._options.forbidClientAccountCreation;
    };

    Template._loginButtonsFormField.inputType = function() {
        return this.inputType || "text";
    };


    //
    // loginButtonsChangePassword template
    //

    Template._loginButtonsChangePassword.events({
        'keypress #login-old-password, keypress #login-password, keypress #login-password-again': function(event) {
            if (event.keyCode === 13)
                changePassword();
        },
        'click #login-buttons-do-change-password': function(event) {
            event.stopPropagation();
            changePassword();
        }
    });

    Template._loginButtonsChangePassword.fields = function() {
        return [{
            fieldName: 'old-password',
            fieldLabel: 'Current Password',
            fieldIcon: 'key',
            inputType: 'password',
            visible: function() {
                return true;
            }
        }, {
            fieldName: 'password',
            fieldLabel: 'New Password',
            fieldIcon: 'asterisk',
            inputType: 'password',
            visible: function() {
                return true;
            }
        }, {
            fieldName: 'password-again',
            fieldLabel: 'New Password (again)',
            inputType: 'password',
            visible: function() {
                // No need to make users double-enter their password if
                // they'll necessarily have an email set, since they can use
                // the "forgot password" flow.
                return _.contains(
                    ["USERNAME_AND_OPTIONAL_EMAIL", "USERNAME_ONLY"],
                    Accounts.ui._passwordSignupFields());
            }
        }];
    };


    //
    // helpers
    //

    var elementValueById = function(id) {
        var element = document.getElementById(id);
        if (!element)
            return null;
        else
            return element.value;
    };

    var trimmedElementValueById = function(id) {
        var element = document.getElementById(id);
        if (!element)
            return null;
        else
            return element.value.replace(/^\s*|\s*$/g, ""); // trim;
    };

    var loginOrSignup = function() {
        if (loginButtonsSession.get('inSignupFlow'))
            signup();
        else
            login();
    };

    var login = function() {
        loginButtonsSession.resetMessages();

        var username = trimmedElementValueById('login-username');
        var email = trimmedElementValueById('login-email');
        var usernameOrEmail = trimmedElementValueById('login-username-or-email');
        // notably not trimmed. a password could (?) start or end with a space
        var password = elementValueById('login-password');

        var loginSelector;
        if (username !== null) {
            if (!Accounts._loginButtons.validateUsername(username))
                return;
            else
                loginSelector = {
                    username: username
                };
        } else if (email !== null) {
            if (!Accounts._loginButtons.validateEmail(email))
                return;
            else
                loginSelector = {
                    email: email
                };
        } else if (usernameOrEmail !== null) {
            // XXX not sure how we should validate this. but this seems good enough (for now),
            // since an email must have at least 3 characters anyways
            if (!Accounts._loginButtons.validateUsername(usernameOrEmail))
                return;
            else
                loginSelector = usernameOrEmail;
        } else {
            throw new Error("Unexpected -- no element to use as a login user selector");
        }

        Meteor.loginWithPassword(loginSelector, password, function(error, result) {
            if (error) {
                loginButtonsSession.errorMessage(error.reason || "Unknown error");
            } else {
                loginButtonsSession.closeDropdown();
            }
        });
    };

    var toggleDropdown = function() {
        $('#login-dropdown-list .dropdown-menu').dropdown('toggle');
    };

    var signup = function() {
        loginButtonsSession.resetMessages();

        var options = {}; // to be passed to Accounts.createUser

        var username = trimmedElementValueById('login-username');
        if (username !== null) {
            if (!Accounts._loginButtons.validateUsername(username))
                return;
            else
                options.username = username;
        }

        var email = trimmedElementValueById('login-email');
        if (email !== null) {
            if (!Accounts._loginButtons.validateEmail(email))
                return;
            else
                options.email = email;
        }

        // notably not trimmed. a password could (?) start or end with a space
        var password = elementValueById('login-password');
        if (!Accounts._loginButtons.validatePassword(password))
            return;
        else
            options.password = password;

        if (!matchPasswordAgainIfPresent())
            return;

        // prepare the profile object
        options.profile = {};

        // define a proxy function to allow extraSignupFields set error messages
        var errorFn = function(errorMessage) {
            Accounts._loginButtonsSession.errorMessage(errorMessage);
        };

        var invalidExtraSignupFields = false;

        // parse extraSignupFields to populate account's profile data
        _.each(Accounts.ui._options.extraSignupFields, function(field, index) {
            var value = elementValueById('login-' + field.fieldName);
            if (typeof field.validate === 'function') {
                if (field.validate(value, errorFn)) {
                    options.profile[field.fieldName] = elementValueById('login-' + field.fieldName);
                } else {
                    invalidExtraSignupFields = true;
                }
            } else {
                options.profile[field.fieldName] = elementValueById('login-' + field.fieldName);
            }
        });

        if (invalidExtraSignupFields)
            return;

        Accounts.createUser(options, function(error) {
            if (error) {
                loginButtonsSession.errorMessage(error.reason || "Unknown error");
            } else {
                loginButtonsSession.closeDropdown();
            }
        });
    };

    var forgotPassword = function() {
        loginButtonsSession.resetMessages();

        var email = trimmedElementValueById("forgot-password-email");
        if (email.indexOf('@') !== -1) {
            Accounts.forgotPassword({
                email: email
            }, function(error) {
                if (error)
                    loginButtonsSession.errorMessage(error.reason || "Unknown error");
                else
                    loginButtonsSession.infoMessage("Email sent");
            });
        } else {
            loginButtonsSession.infoMessage("Email sent");
        }
    };

    var changePassword = function() {
        loginButtonsSession.resetMessages();

        // notably not trimmed. a password could (?) start or end with a space
        var oldPassword = elementValueById('login-old-password');

        // notably not trimmed. a password could (?) start or end with a space
        var password = elementValueById('login-password');
        if (!Accounts._loginButtons.validatePassword(password))
            return;

        if (!matchPasswordAgainIfPresent())
            return;

        Accounts.changePassword(oldPassword, password, function(error) {
            if (error) {
                loginButtonsSession.errorMessage(error.reason || "Unknown error");
            } else {
                loginButtonsSession.infoMessage("Password changed");

                // wait 3 seconds, then expire the msg
                Meteor.setTimeout(function() {
                    loginButtonsSession.resetMessages();
                }, 3000);
            }
        });
    };

    var matchPasswordAgainIfPresent = function() {
        // notably not trimmed. a password could (?) start or end with a space
        var passwordAgain = elementValueById('login-password-again');
        if (passwordAgain !== null) {
            // notably not trimmed. a password could (?) start or end with a space
            var password = elementValueById('login-password');
            if (password !== passwordAgain) {
                loginButtonsSession.errorMessage("Passwords don't match");
                return false;
            }
        }
        return true;
    };
})();
(function () {
  // for convenience
  var loginButtonsSession = Accounts._loginButtonsSession;


  //
  // populate the session so that the appropriate dialogs are
  // displayed by reading variables set by accounts-urls, which parses
  // special URLs. since accounts-ui depends on accounts-urls, we are
  // guaranteed to have these set at this point.
  //

  if (Accounts._resetPasswordToken) {
    loginButtonsSession.set('resetPasswordToken', Accounts._resetPasswordToken);
  }

  if (Accounts._enrollAccountToken) {
    loginButtonsSession.set('enrollAccountToken', Accounts._enrollAccountToken);
  }

  // Needs to be in Meteor.startup because of a package loading order
  // issue. We can't be sure that accounts-password is loaded earlier
  // than accounts-ui so Accounts.verifyEmail might not be defined.
  Meteor.startup(function () {
    if (Accounts._verifyEmailToken) {
      Accounts.verifyEmail(Accounts._verifyEmailToken, function(error) {
        Accounts._enableAutoLogin();
        if (!error)
          loginButtonsSession.set('justVerifiedEmail', true);
        // XXX show something if there was an error.
      });
    }
  });


  //
  // resetPasswordDialog template
  //
  Template._resetPasswordDialog.rendered = function() {
    var $modal = $(this.find('#login-buttons-reset-password-modal'));
    $modal.modal();
  }

  Template._resetPasswordDialog.events({
    'click #login-buttons-reset-password-button': function () {
      resetPassword();
    },
    'keypress #reset-password-new-password': function (event) {
      if (event.keyCode === 13)
        resetPassword();
    },
    'click #login-buttons-cancel-reset-password': function () {
      loginButtonsSession.set('resetPasswordToken', null);
      Accounts._enableAutoLogin();
      $('#login-buttons-reset-password-modal').modal("hide");
    }
  });

  var resetPassword = function () {
    loginButtonsSession.resetMessages();
    var newPassword = document.getElementById('reset-password-new-password').value;
    if (!Accounts._loginButtons.validatePassword(newPassword))
      return;

    Accounts.resetPassword(
      loginButtonsSession.get('resetPasswordToken'), newPassword,
      function (error) {
        if (error) {
          loginButtonsSession.errorMessage(error.reason || "Unknown error");
        } else {
          loginButtonsSession.set('resetPasswordToken', null);
          Accounts._enableAutoLogin();
          $('#login-buttons-reset-password-modal').modal("hide");
        }
      });
  };

  Template._resetPasswordDialog.inResetPasswordFlow = function () {
    return loginButtonsSession.get('resetPasswordToken');
  };


  //
  // enrollAccountDialog template
  //

  Template._enrollAccountDialog.events({
    'click #login-buttons-enroll-account-button': function () {
      enrollAccount();
    },
    'keypress #enroll-account-password': function (event) {
      if (event.keyCode === 13)
        enrollAccount();
    },
    'click #login-buttons-cancel-enroll-account-button': function () {
      loginButtonsSession.set('enrollAccountToken', null);
      Accounts._enableAutoLogin();
      $modal.modal("hide");
    }
  });

  Template._enrollAccountDialog.rendered = function() {
    $modal = $(this.find('#login-buttons-enroll-account-modal'));
    $modal.modal();
  };

  var enrollAccount = function () {
    loginButtonsSession.resetMessages();
    var password = document.getElementById('enroll-account-password').value;
    if (!Accounts._loginButtons.validatePassword(password))
      return;

    Accounts.resetPassword(
      loginButtonsSession.get('enrollAccountToken'), password,
      function (error) {
        if (error) {
          loginButtonsSession.errorMessage(error.reason || "Unknown error");
        } else {
          loginButtonsSession.set('enrollAccountToken', null);
          Accounts._enableAutoLogin();
          $modal.modal("hide");
        }
      });
  };

  Template._enrollAccountDialog.inEnrollAccountFlow = function () {
    return loginButtonsSession.get('enrollAccountToken');
  };


  //
  // justVerifiedEmailDialog template
  //

  Template._justVerifiedEmailDialog.events({
    'click #just-verified-dismiss-button': function () {
      loginButtonsSession.set('justVerifiedEmail', false);
    }
  });

  Template._justVerifiedEmailDialog.visible = function () {
    return loginButtonsSession.get('justVerifiedEmail');
  };


  //
  // loginButtonsMessagesDialog template
  //

  // Template._loginButtonsMessagesDialog.rendered = function() {
  //   var $modal = $(this.find('#configure-login-service-dialog-modal'));
  //   $modal.modal();
  // }

  Template._loginButtonsMessagesDialog.events({
    'click #messages-dialog-dismiss-button': function () {
      loginButtonsSession.resetMessages();
    }
  });

  Template._loginButtonsMessagesDialog.visible = function () {
    var hasMessage = loginButtonsSession.get('infoMessage') || loginButtonsSession.get('errorMessage');
    return !Accounts._loginButtons.dropdown() && hasMessage;
  };


  //
  // configureLoginServiceDialog template
  //

  Template._configureLoginServiceDialog.events({
    'click .configure-login-service-dismiss-button': function () {
      loginButtonsSession.set('configureLoginServiceDialogVisible', false);
    },
    'click #configure-login-service-dialog-save-configuration': function () {
      if (loginButtonsSession.get('configureLoginServiceDialogVisible') &&
          ! loginButtonsSession.get('configureLoginServiceDialogSaveDisabled')) {
        // Prepare the configuration document for this login service
        var serviceName = loginButtonsSession.get('configureLoginServiceDialogServiceName');
        var configuration = {
          service: serviceName
        };
        _.each(configurationFields(), function(field) {
          configuration[field.property] = document.getElementById(
            'configure-login-service-dialog-' + field.property).value
            .replace(/^\s*|\s*$/g, ""); // trim;
        });

        // Configure this login service
        Meteor.call("configureLoginService", configuration, function (error, result) {
          if (error)
            Meteor._debug("Error configuring login service " + serviceName, error);
          else
            loginButtonsSession.set('configureLoginServiceDialogVisible', false);
        });
      }
    },
    // IE8 doesn't support the 'input' event, so we'll run this on the keyup as
    // well. (Keeping the 'input' event means that this also fires when you use
    // the mouse to change the contents of the field, eg 'Cut' menu item.)
    'input, keyup input': function (event) {
      // if the event fired on one of the configuration input fields,
      // check whether we should enable the 'save configuration' button
      if (event.target.id.indexOf('configure-login-service-dialog') === 0)
        updateSaveDisabled();
    }
  });

  // check whether the 'save configuration' button should be enabled.
  // this is a really strange way to implement this and a Forms
  // Abstraction would make all of this reactive, and simpler.
  var updateSaveDisabled = function () {
    var anyFieldEmpty = _.any(configurationFields(), function(field) {
      return document.getElementById(
        'configure-login-service-dialog-' + field.property).value === '';
    });

    loginButtonsSession.set('configureLoginServiceDialogSaveDisabled', anyFieldEmpty);
  };

  // Returns the appropriate template for this login service.  This
  // template should be defined in the service's package
  var configureLoginServiceDialogTemplateForService = function () {
    var serviceName = loginButtonsSession.get('configureLoginServiceDialogServiceName');
    return Template['configureLoginServiceDialogFor' + capitalize(serviceName)];
  };

  var configurationFields = function () {
    var template = configureLoginServiceDialogTemplateForService();
    return template.fields();
  };

  Template._configureLoginServiceDialog.configurationFields = function () {
    return configurationFields();
  };

  Template._configureLoginServiceDialog.visible = function () {
    return loginButtonsSession.get('configureLoginServiceDialogVisible');
  };

  Template._configureLoginServiceDialog.configurationSteps = function () {
    // renders the appropriate template
    return configureLoginServiceDialogTemplateForService()();
  };

  Template._configureLoginServiceDialog.saveDisabled = function () {
    return loginButtonsSession.get('configureLoginServiceDialogSaveDisabled');
  };


  // XXX from http://epeli.github.com/underscore.string/lib/underscore.string.js
  var capitalize = function(str){
    str = str == null ? '' : String(str);
    return str.charAt(0).toUpperCase() + str.slice(1);
  };

}) ();