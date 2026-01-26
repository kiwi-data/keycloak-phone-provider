<#import "template.ftl" as layout>
<@layout.registrationLayout displayInfo=true displayMessage=!messagesPerField.existsError('username','code','phoneNumber'); section>
    <#if section = "header">
        Reset your password
    <#elseif section = "form">

        <#if supportPhone??>
            <script src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script>
            <script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
            <style>
                [v-cloak] > * { display: none; }
                [v-cloak]::before { content: "loading..."; }
            </style>
        </#if>

        <p class="protocols-subtitle">Enter your details to reset your password.</p>

        <div id="vue-app">
            <div v-cloak>
                <form id="kc-reset-password-form" action="${url.loginAction}" method="post">
                    <script type="text/javascript">
                    document.addEventListener('DOMContentLoaded', function() {
                        var form = document.getElementById('kc-reset-password-form');
                        if (form) {
                            form.addEventListener('submit', function(e) {
                                var phoneInput = document.getElementById('phoneNumber');
                                var countryCode = document.getElementById('countryCode');
                                if (phoneInput && countryCode && phoneInput.value && !phoneInput.value.startsWith('+')) {
                                    phoneInput.value = countryCode.value + phoneInput.value.trim();
                                }
                            });
                        }
                    });
                    </script>
                    
                    <#if supportPhone??>
                    <div class="protocols-alert protocols-alert-error" v-show="errorMessage">
                        {{ errorMessage }}
                    </div>

                    <div class="protocols-tabs">
                        <button type="button" class="protocols-tab" :class="{ active: !phoneActivated }" @click="phoneActivated = false">
                            ${msg("email")}
                        </button>
                        <button type="button" class="protocols-tab" :class="{ active: phoneActivated }" @click="phoneActivated = true">
                            ${msg("phoneNumber")}
                        </button>
                    </div>

                    <input type="hidden" id="phoneActivated" name="phoneActivated" v-model="phoneActivated">
                    </#if>

                    <#-- Email/Username Reset -->
                    <div <#if supportPhone??> v-if="!phoneActivated" </#if>>
                        <div class="protocols-form-group">
                            <label for="username" class="protocols-label">${msg("email")}</label>
                            <input type="text" id="username" name="username" 
                                   class="protocols-input <#if messagesPerField.existsError('username')>has-error</#if>"
                                   placeholder="Enter your email"
                                   autofocus value="${(auth.attemptedUsername!'')}"
                                   aria-invalid="<#if messagesPerField.existsError('username')>true</#if>" />
                            <#if messagesPerField.existsError('username')>
                                <span class="protocols-error-msg">
                                    ${kcSanitize(messagesPerField.get('username'))?no_esc}
                                </span>
                            </#if>
                        </div>
                    </div>

                    <#-- Phone Reset -->
                    <#if supportPhone??>
                    <div v-if="phoneActivated">
                        <div class="protocols-form-group">
                            <label for="phoneNumber" class="protocols-label">${msg("phoneNumber")}</label>
                            <div class="protocols-phone-group">
                                <select class="protocols-country-select" id="countryCode">
                                    <option value="+86">+86</option>
                                </select>
                                <input type="text" id="phoneNumber" name="phoneNumber" v-model="phoneNumber"
                                       class="protocols-input protocols-phone-input <#if messagesPerField.existsError('code','phoneNumber')>has-error</#if>"
                                       placeholder="Your phone number"
                                       aria-invalid="<#if messagesPerField.existsError('code','phoneNumber')>true</#if>" />
                            </div>
                            <#if messagesPerField.existsError('code','phoneNumber')>
                                <span class="protocols-error-msg">
                                    ${kcSanitize(messagesPerField.getFirstError('phoneNumber','code'))?no_esc}
                                </span>
                            </#if>
                        </div>

                        <div class="protocols-form-group">
                            <label for="code" class="protocols-label">${msg("verificationCode")}</label>
                            <div class="protocols-code-group">
                                <input type="text" id="code" name="code"
                                       class="protocols-input protocols-code-input"
                                       placeholder="Your passcode"
                                       autocomplete="one-time-code"
                                       aria-invalid="<#if messagesPerField.existsError('code','phoneNumber')>true</#if>" />
                                <button type="button" class="protocols-send-btn"
                                        :disabled="sendButtonText !== initSendButtonText"
                                        @click="sendVerificationCode()">
                                    {{ sendButtonText }}
                                </button>
                            </div>
                        </div>
                    </div>
                    </#if>

                    <button class="protocols-btn-primary" type="submit">
                        ${msg("doSubmit")}
                    </button>
                    
                    <div class="protocols-footer" style="margin-top: 16px;">
                        <a href="${url.loginUrl}" class="protocols-link">${kcSanitize(msg("backToLogin"))?no_esc}</a>
                    </div>
                </form>
            </div>
        </div>

        <#if supportPhone??>
        <script type="text/javascript">
            function req(phoneNumber) {
                const params = {params: {phoneNumber}}
                axios.get(window.location.origin + '/realms/${realm.name}/sms/reset-code', params)
                    .then(res => app.disableSend(res.data.expires_in))
                    .catch(e => app.errorMessage = e.response.data.error);
            }

            var app = new Vue({
                el: '#vue-app',
                data: {
                    errorMessage: '',
                    freezeSendCodeSeconds: 0,
                    phoneActivated: <#if attemptedPhoneActivated??>true<#else>false</#if>,
                    phoneNumber: '${attemptedPhoneNumber!}',
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
                        const phoneNumber = document.getElementById('phoneNumber').value.trim();
                        if (!phoneNumber) {
                            this.errorMessage = '${msg("requiredPhoneNumber")}';
                            document.getElementById('phoneNumber').focus();
                            return;
                        }
                        if (this.sendButtonText !== this.initSendButtonText) {
                            return;
                        }
                        const countryCode = document.getElementById('countryCode').value;
                        req(countryCode + phoneNumber);
                    }
                }
            });
        </script>
        </#if>

    <#elseif section = "info">
        <#if realm.duplicateEmailsAllowed>
            ${msg("emailInstructionUsername")}
        <#else>
            ${msg("emailInstruction")}
        </#if>
        <#if supportPhone??>
            ${msg("phoneInstruction")}
        </#if>
    </#if>
</@layout.registrationLayout>
