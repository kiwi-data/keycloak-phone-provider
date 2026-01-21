<#import "template.ftl" as layout>
<@layout.registrationLayout displayInfo=true; section>
    <#if section = "header">
        Verify your identity
    <#elseif section = "form">

        <script src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
        <style>
            [v-cloak] > * { display: none; }
            [v-cloak]::before { content: "loading..."; }
        </style>

        <p class="protocols-subtitle">${msg("authCodeInfo")}</p>

        <div id="vue-app">
            <div class="protocols-alert protocols-alert-error" v-show="errorMessage" v-cloak>
                {{ errorMessage }}
            </div>

            <form id="kc-form-login" action="${url.loginAction}" method="post">
                <div class="protocols-form-group">
                    <label for="code" class="protocols-label">${msg("authenticationCode")}</label>
                    <div class="protocols-code-group">
                        <input tabindex="0" id="code" class="protocols-input protocols-code-input" name="code"
                               type="text" autofocus autocomplete="one-time-code"
                               placeholder="Enter verification code" />
                        <button type="button" class="protocols-send-btn"
                                :disabled="sendButtonText !== initSendButtonText"
                                @click="sendVerificationCode()">
                            {{ sendButtonText }}
                        </button>
                    </div>
                </div>

                <input type="hidden" id="id-hidden-input" name="credentialId"
                       <#if auth.selectedCredential?has_content>value="${auth.selectedCredential}"</#if>/>
                <button tabindex="0" class="protocols-btn-primary" name="save" id="kc-login" type="submit">
                    ${msg("doSubmit")}
                </button>
            </form>
        </div>

        <script type="text/javascript" >



            function req(phoneNumber) {
                const params = {params: {phoneNumber}}
                axios.get(window.location.origin + '/realms/${realm.name}/sms/otp-code', params)
                    .then(res => app.disableSend(res.data.expires_in))
                    .catch(e => app.errorMessage = e.response.data.error);
            }

            var app = new Vue({
                el: '#vue-app',
                data: {
                    errorMessage: '',
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
                        if (!this.phoneNumber) {
                            this.errorMessage = '${msg("requiredPhoneNumber")}';
                            document.getElementById('phoneNumber').focus();
                            return;
                        }
                        if (this.sendButtonText !== this.initSendButtonText) {
                            return;
                        }
                        req(this.phoneNumber);

                    }
                }
            });


            <#if initSend??>
            window.addEventListener('load', function () {
                app.disableSend(${expires});
            })
            </#if>

        </script>
    <#elseif section = "info">
        ${msg("authCodeInfo")}
    </#if>
</@layout.registrationLayout>
