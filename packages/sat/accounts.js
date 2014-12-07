Login = {};
Login.loginSession = {
  set: function(key, value) {
    if (_.contains(['errorMessage', 'infoMessage'], key)) {
      throw new Error("Use errorMessage() or infoMessage().");
    }
    return this._set(key, value);
  },
  _set: function(key, value) {
    return Session.set("Meteor.loginButtons." + key, value);
  },
  get: function(key) {
    return Session.get('Meteor.loginButtons.' + key);
  },
  closeDropdown: function() {
    this.set('inSignupFlow', false);
    this.set('inForgotPasswordFlow', false);
    this.set('inChangePasswordFlow', false);
    this.set('inMessageOnlyFlow', false);
    this.set('dropdownVisible', false);
    return this.resetMessages;
  },
  infoMessage: function(message) {
    this._set("errorMessage", null);
    this._set("infoMessage", message);
    return this.ensureMessageVisible;
  },
  errorMessage: function(message) {
    this._set("errorMessage", message);
    this._set("infoMessage", null);
    return this.ensureMessageVisible;
  },
  isMessageDialogVisible: function() {
    return this.get('resetPasswordToken') || this.get('enrollAccountToken') || this.get('justVerifiedEmail');
  },
  ensureMessageVisible: function() {
    if (!this.isMessageDialogVisible) {
      return this.set("dropdownVisible", true);
    }
  },
  resetMessages: function() {
    this._set("errorMessage", null);
    return this._set("infoMessage", null);
  },
  configureService: function(name) {
    this.set('configureLoginServiceDialogVisible', true);
    this.set('configureLoginServiceDialogServiceName', name);
    return this.set('configureLoginServiceDialogSaveDisabled', true);
  }
};

if (Login._resetPasswordToken) {
  Login.loginSession.set('resetPasswordToken', Login._resetPasswordToken);
}

if (Login._enrollAccountToken) {
  Login.loginSession.set('enrollAccountToken', Login._enrollAccountToken);
}

if (!Login.loginButtons) {
  Login.loginButtons = {};
}

Login.loginButtons.displayName = function() {
  var user;
  user = Meteor.user();
  if (!user) {
    return '';
  } else if (user.profile && user.profile.name) {
    return user.profile.name;
  } else if (user.username) {
    return user.username;
  } else if (user.emails && user.emails[0] && user.emails[0].address) {
    return user.emails[0].address;
  } else {
    return '';
  }
};

Login.loginButtons.getLoginServices = function() {
  var services;
  services = Package['accounts-oauth'] ? Login.oauth.serviceNames() : [];
  services.sort();
  if (this.hasPasswordService()) {
    services.push('password');
  }
  return _.map(services, function(name) {
    return {
      name: name
    };
  });
};

Login.loginButtons.hasPasswordService = function() {
  return !!Package['accounts-password'];
};

Login.loginButtons.dropdown = function() {
  return this.hasPasswordService() || Login.loginButtons.getLoginServices().length > 1;
};

Login.loginButtons.validateUsername = function(username) {
  if (username.length >= 3) {
    return true;
  } else {
    return Login.loginSession.errorMessage("Username must be at least 3 characters long" && false);
  }
};

Login.loginButtons.validateEmail = function(email) {
  var re;
  if (Login.ui._passwordSignupFields() === "USERNAME_AND_OPTIONAL_EMAIL" && email === '') {
    return true;
  }
  re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
  if (re.test(email)) {
    return true;
  } else {
    return Login.loginSession.errorMessage("Invalid email" && false);
  }
};

Login.loginButtons.validatePassword = function(password) {
  if (password.length >= 6) {
    return true;
  } else {
    return Login.loginSession.errorMessage("Password must be at least 6 characters long" && false);
  }
};

Login.loginButtons.rendered = function() {
  debugger;
};

Login.ui = {
  _options: {
    requestPermissions: {},
    extraSignupFields: []
  },
  navigate: function(route, hash) {
    return Router.go(route, hash);
  },
  _passwordSignupFields: function() {
    return Login.ui._options.passwordSignupFields || 'USERNAME_AND_EMAIL';
  },
  config: function(options) {
    _.each(_.keys(options), function(key) {
      if (!_.contains(['passwordSignupFields', 'requestPermissions', 'extraSignupFields'], key)) {
        throw new Error("Login.ui.config: Invalid key: " + key);
      }
    });
    if (options.passwordSignupFields) {
      if (_.contains(['USERNAME_AND_EMAIL_CONFIRM', 'USERNAME_AND_EMAIL', 'USERNAME_AND_OPTIONAL_EMAIL', 'USERNAME_ONLY', 'EMAIL_ONLY'], options.passwordSignupFields)) {
        if (Login.ui._options.passwordSignupFields) {
          throw new Error("Login.ui.config: Can't set `passwordSignupFields` more than once");
        } else {
          Login.ui._options.passwordSignupFields = options.passwordSignupFields;
        }
      } else {
        throw new Error('Login.ui.config: Invalid option for `passwordSignupFields`: ' + options.passwordSignupFields);
      }
    }
    if (options.requestPermissions) {
      _.each(options.requestPermissions, function(scope, service) {
        if (Login.ui._options.requestPermissions[service]) {
          throw new Error("Login.ui.config: Can't set `requestPermissions` more than once for " + service);
        } else if (!(scope instanceof Array)) {
          throw new Error('Login.ui.config: Value for `requestPermissions` must be an array');
        } else {
          return Login.ui._options.requestPermissions[service] = scope;
        }
      });
      if (typeof options.extraSignupFields !== 'object' || !options.extraSignupFields instanceof Array) {
        throw new Error('Login.ui.config: `extraSignupFields` must be an array.');
      } else {
        if (options.extraSignupFields) {
          return _.each(options.extraSignupFields, function(field, index) {
            if (!field.fieldName || !field.fieldLabel) {
              throw new Error('Login.ui.config: `extraSignupFields` objects must have `fieldName` and `fieldLabel` attributes.');
            }
            if (typeof field.visible === 'undefined') {
              field.visible = true;
            }
            return Login.ui._options.extraSignupFields[index] = field;
          });
        }
      }
    }
  },
  changePassword: function() {
    var oldPassword, password;
    Login.loginSession.resetMessages();
    oldPassword = __.getValue('old-password');
    password = __.getValue('password');
    if (!Login.loginButtons.validatePassword(password || !Login.ui.matchPasswordAgainIfPresent())) {
      return;
    }
    return Login.changePassword(oldPassword, password, function(error) {
      if (error) {
        return Login.loginSession.errorMessage(error.reason || "Unknown error");
      } else {
        Login.loginSession.infoMessage("Password changed");
        return Meteor.setTimeout(function() {
          Login.loginSession.resetMessages();
          Login.loginSession.closeDropdown();
          return $('#login-dropdown-list').removeClass('open');
        }, 3000);
      }
    });
  },
  matchPasswordAgainIfPresent: function() {
    var password, passwordAgain;
    passwordAgain = __.getValue('password-again');
    if (passwordAgain !== null) {
      password = __.getValue('password');
      if (password !== passwordAgain) {
        Login.loginSession.errorMessage("Passwords don't match");
        return false;
      }
    }
    return true;
  },
  resetPassword: function() {
    var newPassword;
    Login.loginSession.resetMessages();
    newPassword = document.getElementById('reset-password-new-password').value;
    if (!Login.loginButtons.validatePassword(newPassword)) {
      return;
    }
    return Login.resetPassword(Login.loginSession.get('resetPasswordToken'), newPassword, function(error) {
      if (error) {
        return Login.loginSession.errorMessage(error.reason || "Unknown error");
      } else {
        Login.loginSession.set('resetPasswordToken', null);
        Login._enableAutoLogin();
        return $('#login-buttons-reset-password-modal').modal("hide");
      }
    });
  },
  enrollAccount: function() {
    var password;
    Login.loginSession.resetMessages();
    password = document.getElementById('enroll-account-password').value;
    if (!Login.loginButtons.validatePassword(password)) {
      return;
    }
    return Login.resetPassword(Login.loginSession.get('enrollAccountToken'), password, function(error) {
      if (error) {
        return Login.loginSession.errorMessage(error.reason || "Unknown error");
      } else {
        Login.loginSession.set('enrollAccountToken', null);
        Login._enableAutoLogin();
        return $modal.modal("hide");
      }
    });
  },
  login: function() {
    var email, loginSelector, password, username, usernameOrEmail;
    Login.loginSession.resetMessages();
    username = __.getValue('username');
    email = __.getValue('email');
    usernameOrEmail = __.trim(__.getValue('username-or-email'));
    password = __.getValue('password');
    loginSelector = void 0;
    if (username !== null) {
      if (!Login.loginButtons.validateUsername(username)) {
        return;
      } else {
        loginSelector = {
          username: username
        };
      }
    } else if (email !== null) {
      if (!Login.loginButtons.validateEmail(email)) {
        return;
      } else {
        loginSelector = {
          email: email
        };
      }
    } else if (usernameOrEmail !== null) {
      if (!Login.loginButtons.validateUsername(usernameOrEmail)) {
        return;
      } else {
        loginSelector = usernameOrEmail;
      }
    } else {
      throw new Error("Unexpected -- no element to use as a login user selector");
    }
    return Meteor.loginWithPassword(loginSelector, password, function(error, result) {
      if (error) {
        return Login.loginSession.errorMessage(error.reason || "Unknown error");
      } else {
        return Login.loginSession.closeDropdown();
      }
    });
  },
  signup: function() {
    var email, errorFn, invalidExtraSignupFields, options, password, username;
    Login.loginSession.resetMessages();
    options = {};
    username = __.trimmedValue('username');
    if (username !== null) {
      if (!Login.loginButtons.validateUsername(username)) {
        return;
      } else {
        options.username = username;
      }
    }
    email = __.trimmedValue('email');
    if (email !== null) {
      if (!Login.loginButtons.validateEmail(email)) {
        return;
      } else {
        options.email = email;
      }
    }
    password = __.getValue('password');
    if (!Login.loginButtons.validatePassword(password)) {
      return;
    } else {
      options.password = password;
    }
    if (!Login.ui.matchPasswordAgainIfPresent()) {
      return;
    }
    options.profile = {};
    errorFn = function(errorMessage) {
      return Login.loginSession.errorMessage(errorMessage);
    };
    invalidExtraSignupFields = false;
    _.each(Login.ui._options.extraSignupFields, function(field, index) {
      var value;
      value = __.getValue(field.fieldName);
      if (typeof field.validate === 'function') {
        if (field.validate(value, errorFn)) {
          return options.profile[field.fieldName] = __.getValue(field.fieldName);
        } else {
          return invalidExtraSignupFields = true;
        }
      } else {
        return options.profile[field.fieldName] = __.getValue(field.fieldName);
      }
    });
    if (invalidExtraSignupFields) {
      return;
    }
    return Accounts.createUser(options, function(error) {
      if (error) {
        return Login.loginSession.errorMessage(error.reason || "Unknown error");
      } else {
        return Login.loginSession.closeDropdown();
      }
    });
  },
  forgotPassword: function() {
    var email;
    Login.loginSession.resetMessages();
    email = __.trimmedValue("forgot-password-email");
    if (email.indexOf('@') !== -1) {
      return Login.forgotPassword({
        email: email
      }, function(error) {
        if (error) {
          return Login.loginSession.errorMessage(error.reason || "Unknown error");
        } else {
          return Login.loginSession.infoMessage("Email sent");
        }
      });
    } else {
      return Login.loginSession.infoMessage("Email sent");
    }
  },
  matchPasswordAgainIfPresent: function() {
    var password, passwordAgain;
    passwordAgain = __.getValue('password-again');
    if (passwordAgain !== null) {
      password = __.getValue('password');
      if (password !== passwordAgain) {
        Login.loginSession.errorMessage("Passwords don't match");
        return false;
      }
    }
    return true;
  },
  loginOrSignup: function() {
    if (Login.loginSession.get('inSignupFlow')) {
      return Login.ui.signup();
    } else {
      return Login.ui.login();
    }
  },
  templateForService: function() {
    var serviceName;
    serviceName = Login.loginSession.get('configureLoginServiceDialogServiceName');
    return Template['configureLoginServiceDialogFor' + _.str.capitalize(serviceName)];
  },
  configurationFields: function() {
    var template;
    template = Login.ui.templateForService();
    return template.fields();
  }
};