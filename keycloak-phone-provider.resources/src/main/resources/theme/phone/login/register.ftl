<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=!messagesPerField.existsError('firstName','lastName','email','username','password','password-confirm','phoneNumber','registerCode'); section>
    <#if section = "header">
        Create your account
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
        <#if phoneNumberRequired??>
            <script src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script>
            <script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
            <style>
                [v-cloak] > * { display: none; }
                [v-cloak]::before { content: "loading..."; }
            </style>
        </#if>
        
        <p class="protocols-subtitle">Welcome to Protocols, create an account to get started.</p>

        <div id="vue-app">
            <#-- Vue Error Message -->
            <#if phoneNumberRequired??>
            <div class="protocols-alert protocols-alert-error" v-show="errorMessage" v-cloak>
                {{ errorMessage }}
            </div>
            </#if>
            
            <#-- Tab Switch - Only show when both phone and email registration are supported -->
            <#if phoneNumberRequired?? && !hideEmail??>
            <div class="protocols-tabs" v-cloak>
                <button type="button" class="protocols-tab" :class="{ active: !phoneRegister }" @click="phoneRegister = false">
                    ${msg("registerByEmail")}
                </button>
                <button type="button" class="protocols-tab" :class="{ active: phoneRegister }" @click="phoneRegister = true">
                    ${msg("registerByPhone")}
                </button>
            </div>
            </#if>
            
            <form id="kc-register-form" action="${url.registrationAction}" method="post">
                <#if phoneNumberRequired?? && !hideEmail??>
                <input type="hidden" id="registerType" name="registerType" :value="phoneRegister ? 'phone' : 'email'">
                </#if>

                <#-- Email Registration Section -->
                <#if phoneNumberRequired?? && !hideEmail??>
                <div v-if="!phoneRegister" v-cloak>
                </#if>
                
                <#if !hideEmail??>
                <div class="protocols-form-group">
                    <label for="email" class="protocols-label">${msg("email")} <span class="required-mark">*</span></label>
                    <input type="email" id="email" class="protocols-input <#if messagesPerField.existsError('email')>has-error</#if>" 
                           name="email" value="${(register.formData.email!'')}" 
                           placeholder="Enter your email"
                           autocomplete="email"
                           required
                           aria-invalid="<#if messagesPerField.existsError('email')>true</#if>" />
                    <#if messagesPerField.existsError('email')>
                        <span class="protocols-error-msg">
                            ${kcSanitize(messagesPerField.get('email'))?no_esc}
                        </span>
                    </#if>
                </div>
                </#if>

                <#-- Username Field (Common) -->
                <div class="protocols-form-group">
                    <label for="username" class="protocols-label">${msg("username")} <span class="required-mark">*</span></label>
                    <input type="text" id="username" class="protocols-input <#if messagesPerField.existsError('username')>has-error</#if>" 
                           name="username" value="${(register.formData.username!'')}" 
                           placeholder="Choose a username"
                           autocomplete="username"
                           required
                           aria-invalid="<#if messagesPerField.existsError('username')>true</#if>" />
                    <#if messagesPerField.existsError('username')>
                        <span class="protocols-error-msg">
                            ${kcSanitize(messagesPerField.get('username'))?no_esc}
                        </span>
                    </#if>
                </div>

                <#if phoneNumberRequired?? && !hideEmail??>
                </div>
                </#if>
                
                <#-- Phone Registration Section -->
                <#if phoneNumberRequired??>
                <#if !hideEmail??>
                <div v-if="phoneRegister" v-cloak>
                </#if>
                    <div class="protocols-form-group">
                        <label for="phoneNumber" class="protocols-label">${msg("phoneNumber")} <span class="required-mark">*</span></label>
                        <div class="protocols-phone-group">
                            <select class="protocols-country-select" name="countryCode" id="countryCode" required>
                                <option value="+86">+86</option>
                            </select>
                            <input tabindex="0" id="phoneNumber" class="protocols-input protocols-phone-input <#if messagesPerField.existsError('phoneNumber')>has-error</#if>" 
                                   name="phoneNumber" type="tel" 
                                   value="${(register.formData.phoneNumber!'')}"
                                   placeholder="Your phone number"
                                   required />
                        </div>
                        <#if messagesPerField.existsError('phoneNumber')>
                            <span class="protocols-error-msg">
                                ${kcSanitize(messagesPerField.get('phoneNumber'))?no_esc}
                            </span>
                        </#if>
                    </div>

                    <#if verifyPhone??>
                    <div class="protocols-form-group">
                        <label for="code" class="protocols-label">${msg("verificationCode")} <span class="required-mark">*</span></label>
                        <div class="protocols-code-group">
                            <input tabindex="0" id="code" class="protocols-input protocols-code-input <#if messagesPerField.existsError('registerCode')>has-error</#if>" 
                                   name="code" type="text" 
                                   placeholder="Your passcode"
                                   autocomplete="one-time-code"
                                   required />
                            <button type="button" class="protocols-send-btn"
                                    v-bind:disabled="sendButtonText !== initSendButtonText"
                                    v-on:click="sendVerificationCode()">
                                {{ sendButtonText }}
                            </button>
                        </div>
                        <#if messagesPerField.existsError('registerCode')>
                            <span class="protocols-error-msg">
                                ${kcSanitize(messagesPerField.get('registerCode'))?no_esc}
                            </span>
                        </#if>
                    </div>
                    </#if>
                    
                    <#-- Username for phone registration -->
                    <div class="protocols-form-group">
                        <label for="username-phone" class="protocols-label">${msg("username")} <span class="required-mark">*</span></label>
                        <input type="text" id="username-phone" class="protocols-input" 
                               name="username" value="${(register.formData.username!'')}" 
                               placeholder="Choose a username"
                               autocomplete="username"
                               required />
                    </div>
                <#if !hideEmail??>
                </div>
                </#if>
                </#if>

                <#-- Name Fields (Common) -->
                <#if !hideName??>
                <div class="protocols-form-group">
                    <label for="firstName" class="protocols-label">${msg("firstName")}</label>
                    <input type="text" id="firstName" class="protocols-input <#if messagesPerField.existsError('firstName')>has-error</#if>" 
                           name="firstName" value="${(register.formData.firstName!'')}" 
                           placeholder="First name"
                           aria-invalid="<#if messagesPerField.existsError('firstName')>true</#if>" />
                    <#if messagesPerField.existsError('firstName')>
                        <span class="protocols-error-msg">
                            ${kcSanitize(messagesPerField.get('firstName'))?no_esc}
                        </span>
                    </#if>
                </div>

                <div class="protocols-form-group">
                    <label for="lastName" class="protocols-label">${msg("lastName")}</label>
                    <input type="text" id="lastName" class="protocols-input <#if messagesPerField.existsError('lastName')>has-error</#if>" 
                           name="lastName" value="${(register.formData.lastName!'')}" 
                           placeholder="Last name"
                           aria-invalid="<#if messagesPerField.existsError('lastName')>true</#if>" />
                    <#if messagesPerField.existsError('lastName')>
                        <span class="protocols-error-msg">
                            ${kcSanitize(messagesPerField.get('lastName'))?no_esc}
                        </span>
                    </#if>
                </div>
                </#if>
                
                <#-- Password Fields (Common) -->
                <#if passwordRequired??>
                <div class="protocols-form-group">
                    <label for="password" class="protocols-label">${msg("password")} <span class="required-mark">*</span></label>
                    <input type="password" id="password" class="protocols-input <#if messagesPerField.existsError('password')>has-error</#if>" 
                           name="password" 
                           placeholder="Create a password"
                           autocomplete="new-password"
                           required
                           aria-invalid="<#if messagesPerField.existsError('password','password-confirm')>true</#if>" />
                    <#if messagesPerField.existsError('password')>
                        <span class="protocols-error-msg">
                            ${kcSanitize(messagesPerField.get('password'))?no_esc}
                        </span>
                    </#if>
                </div>

                <div class="protocols-form-group">
                    <label for="password-confirm" class="protocols-label">${msg("passwordConfirm")} <span class="required-mark">*</span></label>
                    <input type="password" id="password-confirm" class="protocols-input <#if messagesPerField.existsError('password-confirm')>has-error</#if>" 
                           name="password-confirm"
                           placeholder="Confirm your password"
                           required
                           aria-invalid="<#if messagesPerField.existsError('password-confirm')>true</#if>" />
                    <#if messagesPerField.existsError('password-confirm')>
                        <span class="protocols-error-msg">
                            ${kcSanitize(messagesPerField.get('password-confirm'))?no_esc}
                        </span>
                    </#if>
                </div>
                </#if>

                <#-- reCAPTCHA -->
                <#if recaptchaRequired??>
                <div class="protocols-form-group">
                    <div class="g-recaptcha" data-size="compact" data-sitekey="${recaptchaSiteKey}"></div>
                </div>
                </#if>

                <button class="protocols-btn-primary" type="submit">
                    ${msg("doRegister")}
                </button>
                
                <div class="protocols-footer" style="margin-top: 16px;">
                    <a href="${url.loginUrl}" class="protocols-link">${kcSanitize(msg("backToLogin"))?no_esc}</a>
                </div>
            </form>
        </div>

        <#-- JavaScript for phone registration -->
        <#if phoneNumberRequired??>
        <script type="text/javascript">
            function req(phoneNumber) {
                const params = {params: {phoneNumber}}
                axios.get(window.location.origin + '/realms/${realm.name}/sms/registration-code', params)
                    .then(res => app.disableSend(res.data.expires_in))
                    .catch(e => app.errorMessage = e.response.data.error);
            }

            const app = new Vue({
                el: '#vue-app',
                data: {
                    errorMessage: '',
                    phoneRegister: <#if register.formData.phoneNumber?has_content>true<#else>false</#if>,
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
                        const countryCode = document.getElementById('countryCode').value;
                        req(countryCode + phoneNumber);
                    }
                },
                watch: {
                    phoneRegister: function(newVal, oldVal) {
                        if (oldVal !== undefined) {
                            this.errorMessage = '';
                            if (newVal) {
                                const emailField = document.getElementById('email');
                                if (emailField) emailField.value = '';
                            } else {
                                const phoneField = document.getElementById('phoneNumber');
                                if (phoneField) phoneField.value = '';
                                const codeField = document.getElementById('code');
                                if (codeField) codeField.value = '';
                            }
                        }
                    }
                },
                mounted: function() {
                    // Add form submit handler to combine country code and phone number
                    const form = document.getElementById('kc-register-form');
                    if (form) {
                        form.addEventListener('submit', function(e) {
                            if (app.phoneRegister) {
                                const countryCode = document.getElementById('countryCode').value;
                                const phoneNumber = document.getElementById('phoneNumber').value.trim();
                                if (phoneNumber && !phoneNumber.startsWith('+')) {
                                    document.getElementById('phoneNumber').value = countryCode + phoneNumber;
                                }
                            }
                        });
                    }
                }
            });
        </script>
        </#if>
    </#if>
</@layout.registrationLayout>