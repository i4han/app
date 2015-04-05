var isVisible;

isVisible = function(v) {
  if ('function' === typeof v) {
    return v();
  } else if (false === v) {
    return false;
  } else {
    return true;
  }
};

module.exports.ui = {
  html: {
    jade: ' ',
    head: function() {
      return {
        title: this.C.title,
        1: "link(rel='stylesheet' href='" + this.C._.font_style.pt_sans + "')",
        3: "script(type='text/javascript' src='https://maps.googleapis.com/maps/api/js?v=3.exp&signed_in=true&libraries=places')",
        5: "meta(name='viewport', content='initial-scale=1.0, user-scalable=no')",
        6: "meta(charset='utf-8')"
      };
    },
    startup: function() {
      return '';
    },
    styl: function() {
      return {
        html: {
          height: '100%'
        },
        body: {
          height: '100%',
          fontFamily: this.C.$.font_family,
          fontWeight: this.C.$.font_weight
        }
      };
    }
  },
  form: {
    jade: "if visible\n    .input-group.margin-bottom-sm\n       span.input-group-addon: i.fa.fa-fw(class=\"fa-{{icon}}\")\n       input.form-control(id=\"{{id}}\" type=\"{{type}}\" placeholder=\"{{label}}\" title=\"{{title}}\" data-toggle=\"popover\" data-trigger=\"hover\" data-placement=\"right\" data-html=\"true\")",
    helpers: {
      type: function() {
        return this.type || "text";
      },
      visible: function() {
        return isVisible(this.visible);
      },
      id: function() {
        return this.id || x.dasherize(this.label.toLowerCase().trim());
      },
      title: function() {
        return this.title;
      }
    },
    styl$: ".popover\n    font-family 'PT Sans', sans-serif\n    width 200px\n.popover-title\n    font-size 14px                \n.popover-content\n    font-size 12px\n    padding 5px 0px\n.popover-content > ul\n    padding-left 32px\n.popover-inner\n    width 100%"
  },
  address: {
    css: "html, body, #map-canvas {\n  height: 100%;\n  margin: 0px;\n  padding: 0px\n}\n.controls {\n  margin-top: 16px;\n  border: 1px solid transparent;\n  border-radius: 2px 0 0 2px;\n  box-sizing: border-box;\n  -moz-box-sizing: border-box;\n  height: 32px;\n  outline: none;\n  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.3);\n}\n\n#pac-input {\n  background-color: #fff;\n  font-family: Roboto;\n  font-size: 15px;\n  font-weight: 300;\n  margin-left: 12px;\n  padding: 0 11px 0 13px;\n  text-overflow: ellipsis;\n  width: 400px;\n}\n\n#pac-input:focus {\n  border-color: #4d90fe;\n}\n\n.pac-container {\n  font-family: Roboto;\n}\n\n#type-selector {\n  color: #fff;\n  background-color: #4d90fe;\n  padding: 5px 11px 0px 11px;\n}\n\n#type-selector label {\n  font-family: Roboto;\n  font-size: 13px;\n  font-weight: 300;\n}"
  },
  button: {
    jade: "if visible\n    button.btn(class=\"{{class}}\" id=\"{{id}}\" type=\"{{type}}\") {{label}}",
    helpers: {
      type: function() {
        return this.type || "button";
      },
      visible: function() {
        return isVisible(this.visible);
      },
      id: function() {
        return this.id || x.dasherize(this.label.toLowerCase().trim());
      },
      "class": function() {
        return this["class"] || 'btn-primary';
      }
    },
    styl$: ".btn\n    font-family 'PT Sans'\n    width 150px //166\n    border 0\n    margin-top 5px\n.btn-default\n    background-color #f8f8f8  \n.btn-default \n.btn-primary \n.btn-success \n.btn-info \n.btn-warning \n.btn-danger \n.btn-default:hover\n.btn-primary:hover\n.btn-success:hover\n.btn-info:hover\n.btn-warning:hover\n.btn-danger:hover\n    border 0"
  },
  dialog: {
    jade: "button.btn(href=\"#myModal\" role=\"button\" data-toggle=\"modal\") Modal\n.modal.fade#myModal(tabindex=\"-1\" role=\"dialog\" aria-labelledby=\"myModalLabel\" aria-hidden=\"true\")\n    .modal-dialog: .modal-content\n        .modal-header\n            button.close(type=\"button\" data-dismiss=\"modal\" aria-hidden=\"true\") ×\n            h3#myModalLabel {{modalHeader}}\n        .modal-body\n            p {{modalBody}}\n        .modal-footer\n            button.btn(data-dismiss=\"modal\" aria-hidden=\"true\") {{modalCloseButton}}\n            button.btn.btn-primary {{modalActionButton}}",
    helpers: {
      modalHeader: function() {
        return "Modal Header";
      },
      modalBody: function() {
        return "One fine body!";
      },
      modalCloseButton: function() {
        return "Close";
      },
      modalActionButton: function() {
        return "Save Changes";
      }
    },
    styl$: ".modal-backdrop\n    opacity: 0.50"
  },
  a: {
    jade: "if visible\n    a(class=\"{{class}}\" id=\"{{id}}\") {{label}}",
    helpers: {
      visible: function() {
        return isVisible(this.visible);
      },
      id: function() {
        return this.id || x.dasherize(this.label.toLowerCase().trim());
      },
      "class": function() {
        return this["class"];
      }
    }
  },
  menu: {
    jade: "if visible\n    if divider\n        li.divider\n    else\n        li: a(id=\"{{id}}\" class=\"{{class}}\" style=\"{{style}}\")\n            i.fa(class=\"fa-{{icon}}\" class=\"{{icon_class}}\")\n            | {{label}}",
    helpers: {
      visible: function() {
        return isVisible(this.visible);
      },
      id: function() {
        return this.id;
      },
      icon: function() {
        return this.icon;
      },
      "class": function() {
        return this["class"] || 'menu-list';
      },
      style: function() {
        return this.style;
      },
      icon_class: function() {
        return this.icon_class || 'dropdown-menu-icon';
      },
      label: function() {
        return this.label;
      },
      divider: function() {
        if (this.label === '-') {
          return true;
        }
      }
    }
  },
  alert: {
    jade: "if visible\n    .alert(class=\"{{class}}\") {{message}}",
    helpers: {
      visible: function() {
        return isVisible(this.visible) && this.message;
      },
      "class": function() {
        return this["class"] || 'alert-success';
      }
    }
  },
  br: {
    jade$: "br(style='line-height:{{height}};')"
  }
};
