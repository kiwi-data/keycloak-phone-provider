<#import "template.ftl" as layout>
<@layout.registrationLayout displayInfo=true; section>
    <#if section = "header">
        ${msg("configSms2Fa")}
    <#elseif section = "form">

      <script src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script>
      <script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
      <style>
          [v-cloak] > * { display: none; }
          [v-cloak]::before { content: "${msg("protocolsLoading")?js_string}"; }
      </style>

      <p class="protocols-subtitle">${msg("configSms2FaInfo")}</p>

      <div id="vue-app">
          <div class="protocols-alert protocols-alert-error" v-show="errorMessage" v-cloak>
              {{ errorMessage }}
          </div>

          <form id="kc-form-login" action="${url.loginAction}" method="post">
              <div class="protocols-form-group">
                  <label for="phoneNumber" class="protocols-label">${msg("phoneNumber")}</label>
                  <div class="protocols-phone-group">
                      <select class="protocols-country-select" id="countryCode">
                          <option value="+86">+86</option>
                      </select>
                      <input tabindex="0" id="phoneNumber" class="protocols-input protocols-phone-input"
                             name="phoneNumber" type="tel" <#if !phoneNumber??>autofocus</#if>
                             value="${phoneNumber!''}"
                             placeholder="${msg("protocolsPlaceholderPhone")}"
                             autocomplete="mobile tel"/>
                  </div>
              </div>

              <div class="protocols-form-group">
                  <label for="code" class="protocols-label">${msg("verificationCode")}</label>
                  <div class="protocols-code-group">
                      <input tabindex="0" id="code" class="protocols-input protocols-code-input" name="code"
                             type="text" <#if phoneNumber??>autofocus</#if>
                             placeholder="${msg("protocolsPlaceholderPasscode")}"
                             autocomplete="one-time-code"/>
                      <button type="button" class="protocols-send-btn"
                              :disabled="sendButtonText !== initSendButtonText"
                              @click="sendVerificationCode()">
                          {{ sendButtonText }}
                      </button>
                  </div>
              </div>

              <input type="hidden" id="id-hidden-input" name="credentialId"
                     <#if auth.selectedCredential?has_content>value="${auth.selectedCredential}"</#if>/>
              <button tabindex="0" class="protocols-btn-primary" name="save" id="kc-login" type="submit"
                      :disabled="sendButtonText === initSendButtonText">
                  ${msg("doSubmit")}
              </button>
          </form>
      </div>

      <script type="text/javascript">
          function req(phoneNumber) {
              const params = {params: {phoneNumber},kind: "configure"}
              axios.get(window.location.origin + '/realms/${realm.name}/sms/otp-code', params)
                  .then(res => app.disableSend(res.data.expires_in))
                  .catch(e => app.errorMessage = e.response.data.error);
          }

          const app = new Vue({
              el: '#vue-app',
              data: {
                  errorMessage: '',
                  phoneNumber: '',
                  sendButtonText: '${msg("sendVerificationCode")}',
                  initSendButtonText: '${msg("sendVerificationCode")}',
                  disableSend: function (seconds) {
                      if (seconds <= 0) {
                          app.sendButtonText = app.initSendButtonText;
                      } else {
                          const minutes = Math.floor(seconds / 60) + '';
                          const seconds_ = seconds % 60 + '';
                          app.sendButtonText = String(minutes.padStart(2, '0') + ":" + seconds_.padStart(2, '0'));
                          setTimeout(function () {
                              app.disableSend(seconds - 1);
                          }, 1000);
                      }
                  },
                  sendVerificationCode: function () {
                      this.errorMessage = '';
                      const phoneNumber = document.getElementById('phoneNumber').value.trim();
                      if (!phoneNumber) {
                          this.errorMessage = '${msg("requiredPhoneNumber")}';
                          document.getElementById('phoneNumber').focus();
                          return;
                      }
                      if (this.sendButtonText !== this.initSendButtonText) return;
                      req(phoneNumber);
                  }
              }
          });
          <#if phoneNumber??>
          req('${phoneNumber}');
          </#if>
      </script>
    <#elseif section = "info">
        ${msg("configSms2FaInfo")}
    </#if>
</@layout.registrationLayout>
