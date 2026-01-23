<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=!messagesPerField.existsError('username','password') displayInfo=realm.password && realm.registrationAllowed && !registrationDisabled??; section>
    <#if section = "header">
        Hey, let's get started!
    <#elseif section = "socialProviders">
        <#if realm.password && social.providers??>
            <div class="protocols-social-section">
                <#list social.providers as p>
                    <a id="social-${p.alias}" class="protocols-social-btn" href="${p.loginUrl}">
                        <#if p.alias == "google">
                            <img src="${url.resourcesPath}/img/google-icon.svg" alt="Google" />
                        <#elseif p.iconClasses?has_content>
                            <i class="${p.iconClasses!}" aria-hidden="true"></i>
                        </#if>
                        <span>Continue with ${p.displayName!}</span>
                    </a>
                </#list>
            </div>
            <div class="protocols-divider"><span>or</span></div>
        </#if>
    <#elseif section = "form">
        <#if phoneLoginEnabled?? && phoneLoginEnabled>
            <script src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script>
            <script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
            <style>
                [v-cloak] > * { display: none; }
                [v-cloak]::before { content: "loading..."; }
            </style>
        </#if>

        <p class="protocols-subtitle">Welcome to Protocols, please log in to continue.</p>

        <div id="vue-app">
            <#if realm.password>
                <#-- Error Message for Vue -->
                <#if phoneLoginEnabled?? && phoneLoginEnabled>
                <div class="protocols-alert protocols-alert-error" v-show="errorMessage" v-cloak>
                    {{ errorMessage }}
                </div>
                </#if>
                
                <#-- Tab Switch for Phone/Password Login -->
                <#if phoneLoginEnabled?? && phoneLoginEnabled>
                <div class="protocols-tabs" v-cloak>
                    <button type="button" class="protocols-tab" :class="{ active: !phoneLogin }" @click="phoneLogin = false">
                        ${msg("loginByPassword")}
                    </button>
                    <button type="button" class="protocols-tab" :class="{ active: phoneLogin }" @click="phoneLogin = true">
                        ${msg("loginByPhone")}
                    </button>
                </div>
                </#if>

                <#-- Password Login Form -->
                <form id="kc-form-login" onsubmit="login.disabled = true; return true;" action="${url.loginAction}" method="post" 
                      <#if phoneLoginEnabled?? && phoneLoginEnabled>v-show="!phoneLogin" v-cloak</#if>>

                    <#if !usernameHidden??>
                        <div class="protocols-form-group">
                            <label for="username" class="protocols-label">
                                ${msg("emailOrPhoneNumber")}
                            </label>
                            <input tabindex="0" id="username" class="protocols-input <#if messagesPerField.existsError('username','password')>has-error</#if>" 
                                   name="username" value="${(login.username!'')}" type="text" autofocus autocomplete="off"
                                   placeholder="${msg("emailOrPhoneNumber")}"
                                   aria-invalid="<#if messagesPerField.existsError('username','password')>true</#if>" />
                            <#if messagesPerField.existsError('username','password')>
                                <span class="protocols-error-msg">
                                    ${kcSanitize(messagesPerField.getFirstError('username','password'))?no_esc}
                                </span>
                            </#if>
                        </div>
                    </#if>

                    <div class="protocols-form-group">
                        <label for="password" class="protocols-label">${msg("password")}</label>
                        <input tabindex="0" id="password" class="protocols-input <#if messagesPerField.existsError('username','password')>has-error</#if>" 
                               name="password" type="password" autocomplete="off"
                               placeholder="${msg("password")}"
                               aria-invalid="<#if messagesPerField.existsError('username','password')>true</#if>" />
                    </div>

                    <div class="protocols-form-options">
                        <#if realm.rememberMe && !usernameHidden??>
                            <label class="protocols-checkbox-group">
                                <#if login.rememberMe??>
                                    <input tabindex="0" id="rememberMe" name="rememberMe" type="checkbox" checked>
                                <#else>
                                    <input tabindex="0" id="rememberMe" name="rememberMe" type="checkbox">
                                </#if>
                                ${msg("rememberMe")}
                            </label>
                        <#else>
                            <div></div>
                        </#if>
                        <#if realm.resetPasswordAllowed>
                            <a tabindex="0" href="${url.loginResetCredentialsUrl}" class="protocols-link">${msg("doForgotPassword")}</a>
                        </#if>
                    </div>

                    <input type="hidden" id="id-hidden-input" name="credentialId" <#if auth.selectedCredential?has_content>value="${auth.selectedCredential}"</#if>/>
                    <button tabindex="0" class="protocols-btn-primary" name="login" id="kc-login" type="submit">
                        ${msg("doLogIn")}
                    </button>
                </form>

                <#-- Phone Login Form -->
                <#if phoneLoginEnabled?? && phoneLoginEnabled>
                <form id="kc-form-phone-login" action="${url.loginAction}" method="post" v-show="phoneLogin" v-cloak>
                    <input type="hidden" name="authType" value="phone" />
                    
                    <div class="protocols-form-group">
                        <label for="phoneNumber" class="protocols-label">${msg("phoneNumber")}</label>
                        <div class="protocols-phone-group">
                            <select class="protocols-country-select" name="countryCode" id="countryCode">
                                <option value="+86">+86</option>
                            </select>
                            <input tabindex="0" id="phoneNumber" class="protocols-input protocols-phone-input" 
                                   name="phoneNumber" type="tel" 
                                   placeholder="Your phone number"
                                   v-model="phoneNumber" />
                        </div>
                    </div>

                    <div class="protocols-form-group">
                        <label for="code" class="protocols-label">${msg("verificationCode")}</label>
                        <div class="protocols-code-group">
                            <input tabindex="0" id="code" class="protocols-input protocols-code-input" 
                                   name="code" type="text" 
                                   placeholder="Your passcode"
                                   autocomplete="one-time-code" />
                            <button type="button" class="protocols-send-btn"
                                    :disabled="sendButtonText !== initSendButtonText"
                                    @click="sendVerificationCode()">
                                {{ sendButtonText }}
                            </button>
                        </div>
                    </div>

                    <button tabindex="0" class="protocols-btn-primary" name="login" type="submit">
                        ${msg("doLogIn")}
                    </button>
                </form>
                </#if>
            </#if>
        </div>

        <#-- Vue.js Script for Phone Login -->
        <#if phoneLoginEnabled?? && phoneLoginEnabled>
        <script type="text/javascript">
            function reqLoginCode(phoneNumber) {
                const params = { params: { phoneNumber: phoneNumber } };
                axios.get(window.location.origin + '/realms/${realm.name}/sms/authentication-code', params)
                    .then(res => app.disableSend(res.data.expires_in))
                    .catch(e => app.errorMessage = e.response.data.error);
            }

            const app = new Vue({
                el: '#vue-app',
                data: {
                    errorMessage: '',
                    phoneLogin: false,
                    phoneNumber: '',
                    sendButtonText: '${msg("sendVerificationCode")}',
                    initSendButtonText: '${msg("sendVerificationCode")}',
                    disableSend: function(seconds) {
                        if (seconds <= 0) {
                            app.sendButtonText = app.initSendButtonText;
                        } else {
                            const minutes = Math.floor(seconds / 60) + '';
                            const seconds_ = seconds % 60 + '';
                            app.sendButtonText = String(minutes.padStart(2, '0') + ":" + seconds_.padStart(2, '0'));
                            setTimeout(function() {
                                app.disableSend(seconds - 1);
                            }, 1000);
                        }
                    },
                    sendVerificationCode: function() {
                        this.errorMessage = '';
                        const phoneNumber = document.getElementById('phoneNumber').value.trim();
                        if (!phoneNumber) {
                            this.errorMessage = '${msg("requiredPhoneNumber")}';
                            document.getElementById('phoneNumber').focus();
                            return;
                        }
                        if (this.sendButtonText !== this.initSendButtonText) return;
                        const countryCode = document.getElementById('countryCode').value;
                        reqLoginCode(countryCode + phoneNumber);
                    }
                }
            });
        </script>
        </#if>

    <#elseif section = "info">
        <#if realm.password && realm.registrationAllowed && !registrationDisabled??>
            <span>${msg("noAccount")} <a tabindex="0" href="${url.registrationUrl}" class="protocols-link">${msg("doRegister")}</a></span>
        </#if>
    </#if>
</@layout.registrationLayout>
