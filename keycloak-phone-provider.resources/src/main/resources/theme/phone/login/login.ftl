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
        <#-- Always load Vue.js for tab switching -->
        <script src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
        <style>
            [v-cloak] > * { display: none; }
            [v-cloak]::before { content: "loading..."; }
        </style>

        <p class="protocols-subtitle">Welcome to Protocols, please log in to continue.</p>

        <div id="vue-app">
            <#if realm.password>
                <#-- Error Message -->
                <div class="protocols-alert protocols-alert-error" v-show="errorMessage" v-cloak>
                    {{ errorMessage }}
                </div>
                
                <#-- Tab Switch for Phone OTP / Password Login (only when phoneLoginEnabled) -->
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
                <form id="kc-form-login" onsubmit="return handlePasswordLoginSubmit()" action="${url.loginAction}" method="post" 
                      <#if phoneLoginEnabled?? && phoneLoginEnabled>v-show="!phoneLogin" v-cloak</#if>>

                    <#if !usernameHidden??>
                        <#-- Sub-Tab Switch: Phone / Email for password login -->
                        <div class="protocols-tabs" v-cloak>
                            <button type="button" class="protocols-tab" :class="{ active: usePhone }" @click="setUsePhone(true)">
                                ${msg("loginByPhoneNumber")}
                            </button>
                            <button type="button" class="protocols-tab" :class="{ active: !usePhone }" @click="setUsePhone(false)">
                                ${msg("loginByEmailAddress")}
                            </button>
                        </div>

                        <#-- Email/Username Mode -->
                        <div class="protocols-form-group" v-show="!usePhone" v-cloak>
                            <label for="emailInput" class="protocols-label">
                                ${msg("email")}
                            </label>
                            <input tabindex="0" id="emailInput" class="protocols-input <#if messagesPerField.existsError('username','password')>has-error</#if>" 
                                   type="text" autofocus autocomplete="off"
                                   placeholder="${msg("email")}"
                                   aria-invalid="<#if messagesPerField.existsError('username','password')>true</#if>" />
                            <#if messagesPerField.existsError('username','password')>
                                <span class="protocols-error-msg">
                                    ${kcSanitize(messagesPerField.getFirstError('username','password'))?no_esc}
                                </span>
                            </#if>
                        </div>

                        <#-- Phone Number Mode -->
                        <div class="protocols-form-group" v-show="usePhone" v-cloak>
                            <label for="phoneNumberInput" class="protocols-label">
                                ${msg("phoneNumber")}
                            </label>
                            <div class="protocols-phone-group">
                                <select class="protocols-country-select" id="pwdCountryCode">
                                    <option value="+86">+86</option>
                                </select>
                                <input tabindex="0" id="phoneNumberInput" class="protocols-input protocols-phone-input <#if messagesPerField.existsError('username','password')>has-error</#if>" 
                                       type="tel" autocomplete="off"
                                       placeholder="${msg("phoneNumber")}"
                                       aria-invalid="<#if messagesPerField.existsError('username','password')>true</#if>" />
                            </div>
                            <#if messagesPerField.existsError('username','password')>
                                <span class="protocols-error-msg">
                                    ${kcSanitize(messagesPerField.getFirstError('username','password'))?no_esc}
                                </span>
                            </#if>
                        </div>

                        <#-- Hidden username field for form submission -->
                        <input type="hidden" id="username" name="username" value="${(login.username!'')}" />
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

        <#-- Vue.js Script -->
        <script type="text/javascript">
            <#if phoneLoginEnabled?? && phoneLoginEnabled>
            function reqLoginCode(phoneNumber) {
                const params = { params: { phoneNumber: phoneNumber } };
                axios.get(window.location.origin + '/realms/${realm.name}/sms/authentication-code', params)
                    .then(res => app.disableSend(res.data.expires_in))
                    .catch(e => app.errorMessage = e.response.data.error);
            }
            </#if>

            // Handle password login form submission
            function handlePasswordLoginSubmit() {
                const loginBtn = document.getElementById('kc-login');
                if (loginBtn) loginBtn.disabled = true;
                
                // If using phone mode, combine country code and phone number
                if (app && app.usePhone) {
                    const countryCode = document.getElementById('pwdCountryCode').value;
                    const phoneNumber = document.getElementById('phoneNumberInput').value.trim();
                    document.getElementById('username').value = countryCode + phoneNumber;
                } else {
                    // Using email mode, copy email input to username
                    const emailInput = document.getElementById('emailInput');
                    if (emailInput) {
                        document.getElementById('username').value = emailInput.value.trim();
                    }
                }
                return true;
            }

            const app = new Vue({
                el: '#vue-app',
                data: {
                    errorMessage: '',
                    phoneLogin: false,
                    usePhone: localStorage.getItem('login_use_phone') === 'true',
                    phoneNumber: '',
                    sendButtonText: '${msg("sendVerificationCode")}',
                    initSendButtonText: '${msg("sendVerificationCode")}',
                },
                methods: {
                    setUsePhone: function(value) {
                        this.usePhone = value;
                        localStorage.setItem('login_use_phone', value);
                    },
                    <#if phoneLoginEnabled?? && phoneLoginEnabled>
                    disableSend: function(seconds) {
                        if (seconds <= 0) {
                            this.sendButtonText = this.initSendButtonText;
                        } else {
                            const minutes = Math.floor(seconds / 60) + '';
                            const seconds_ = seconds % 60 + '';
                            this.sendButtonText = String(minutes.padStart(2, '0') + ":" + seconds_.padStart(2, '0'));
                            setTimeout(() => {
                                this.disableSend(seconds - 1);
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
                    </#if>
                },
                mounted: function() {
                    // Restore previous login username to the correct input field
                    const savedUsername = '${(login.username!'')?js_string}';
                    if (savedUsername) {
                        if (this.usePhone && savedUsername.startsWith('+')) {
                            // It's a phone number, try to parse it
                            const phoneInput = document.getElementById('phoneNumberInput');
                            const countrySelect = document.getElementById('pwdCountryCode');
                            if (phoneInput && countrySelect) {
                                // Try to match country code
                                const options = countrySelect.options;
                                for (let i = 0; i < options.length; i++) {
                                    if (savedUsername.startsWith(options[i].value)) {
                                        countrySelect.value = options[i].value;
                                        phoneInput.value = savedUsername.substring(options[i].value.length);
                                        break;
                                    }
                                }
                            }
                        } else {
                            // It's an email/username
                            const emailInput = document.getElementById('emailInput');
                            if (emailInput) {
                                emailInput.value = savedUsername;
                            }
                        }
                    }
                }
            });
        </script>

    <#elseif section = "info">
        <#if realm.password && realm.registrationAllowed && !registrationDisabled??>
            <span>${msg("noAccount")} <a tabindex="0" href="${url.registrationUrl}" class="protocols-link">${msg("doRegister")}</a></span>
        </#if>
    </#if>
</@layout.registrationLayout>
