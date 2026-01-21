<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=!messagesPerField.existsError('firstName','lastName','email','username','password','password-confirm','phoneNumber','registerCode'); section>
    <#if section = "header">
        ${msg("registerTitle")}
    <#elseif section = "form">
        <#if phoneNumberRequired??>
            <script src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script>
            <script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
            <style>
                [v-cloak] > * {
                    display: none;
                }
                [v-cloak]::before {
                    content: "loading...";
                }
            </style>
        </#if>
        <div id="vue-app">
        <form id="kc-register-form" class="${properties.kcFormClass!}" action="${url.registrationAction}" method="post">
            
            <#-- Tab切换 - 只在同时支持手机号和邮箱注册时显示 -->
            <#if phoneNumberRequired?? && !hideEmail??>
            <div class="alert-error ${properties.kcAlertClass!} pf-m-danger" v-show="errorMessage">
                <div class="pf-c-alert__icon">
                    <span class="${properties.kcFeedbackErrorIcon!}"></span>
                </div>
                <span class="${properties.kcAlertTitleClass!}">{{ errorMessage }}</span>
            </div>
            
            <div class="${properties.kcFormGroupClass!}">
                <div class="${properties.kcLabelWrapperClass!}">
                    <ul class="nav nav-pills nav-justified">
                        <li role="presentation" v-bind:class="{ active: !phoneRegister }"
                            v-on:click="phoneRegister = false">
                            <a href="#">${msg("registerByEmail")}</a>
                        </li>
                        <li role="presentation" v-bind:class="{ active: phoneRegister }"
                            v-on:click="phoneRegister = true">
                            <a href="#">${msg("registerByPhone")}</a>
                        </li>
                    </ul>
                </div>
            </div>
            
            <input type="hidden" id="registerType" name="registerType" :value="phoneRegister ? 'phone' : 'email'">
            <#else>
            <#if phoneNumberRequired??>
            <div class="alert-error ${properties.kcAlertClass!} pf-m-danger" v-show="errorMessage">
                <div class="pf-c-alert__icon">
                    <span class="${properties.kcFeedbackErrorIcon!}"></span>
                </div>
                <span class="${properties.kcAlertTitleClass!}">{{ errorMessage }}</span>
            </div>
            </#if>
            </#if>

            <#-- 邮箱注册区域 -->
            <#if phoneNumberRequired?? && !hideEmail??>
            <div v-if="!phoneRegister" v-cloak>
            </#if>
            
            <#if !hideEmail??>
            <div class="${properties.kcFormGroupClass!}">
                <div class="${properties.kcLabelWrapperClass!}">
                    <label for="email" class="${properties.kcLabelClass!}">${msg("email")}</label>
                </div>
                <div class="${properties.kcInputWrapperClass!}">
                    <input type="text" id="email" class="${properties.kcInputClass!}" name="email"
                           value="${(register.formData.email!'')}" autocomplete="email"
                           aria-invalid="<#if messagesPerField.existsError('email')>true</#if>"
                    />

                    <#if messagesPerField.existsError('email')>
                        <span id="input-error-email" class="${properties.kcInputErrorMessageClass!}" aria-live="polite">
                            ${kcSanitize(messagesPerField.get('email'))?no_esc}
                        </span>
                    </#if>
                </div>
            </div>
            </#if>

            <#-- Username 字段（公共，始终显示） -->
            <div class="${properties.kcFormGroupClass!}">
                <div class="${properties.kcLabelWrapperClass!}">
                    <label for="username" class="${properties.kcLabelClass!}">${msg("username")}</label>
                </div>
                <div class="${properties.kcInputWrapperClass!}">
                    <input type="text" id="username" class="${properties.kcInputClass!}" name="username"
                           value="${(register.formData.username!'')}" autocomplete="username"
                           aria-invalid="<#if messagesPerField.existsError('username')>true</#if>"
                    />

                    <#if messagesPerField.existsError('username')>
                        <span id="input-error-username" class="${properties.kcInputErrorMessageClass!}" aria-live="polite">
                            ${kcSanitize(messagesPerField.get('username'))?no_esc}
                        </span>
                    </#if>
                </div>
            </div>

            <#if phoneNumberRequired?? && !hideEmail??>
            </div>
            </#if>
            
            <#-- 手机号注册区域 -->
            <#if phoneNumberRequired??>
            <#if !hideEmail??>
            <div v-if="phoneRegister" v-cloak>
            </#if>
                <div class="${properties.kcFormGroupClass!} ${messagesPerField.printIfExists('phoneNumber',properties.kcFormGroupErrorClass!)}">
                    <div class="${properties.kcLabelWrapperClass!}">
                        <label for="phoneNumber" class="${properties.kcLabelClass!}">${msg("phoneNumber")}</label>
                    </div>
                    <div class="${properties.kcInputWrapperClass!}">
                        <input tabindex="0" id="phoneNumber" class="${properties.kcInputClass!}"
                               name="phoneNumber" type="tel"
                               aria-invalid="<#if messagesPerField.existsError('phoneNumber')>true</#if>"
                               autofocus
                               value="${(register.formData.phoneNumber!'')}"
                               autocomplete="mobile tel"/>
                        <#if messagesPerField.existsError('phoneNumber')>
                            <span id="input-error-phonenumber" class="${properties.kcInputErrorMessageClass!}" aria-live="polite">
                                ${kcSanitize(messagesPerField.get('phoneNumber'))?no_esc}
                            </span>
                        </#if>
                    </div>
                </div>

                <#if verifyPhone??>
                <div class="${properties.kcFormGroupClass!} row">
                    <div class="${properties.kcLabelWrapperClass!}" style="padding: 0">
                        <label for="registerCode" class="${properties.kcLabelClass!}">${msg("verificationCode")}</label>
                    </div>
                    <div class="col-xs-8" style="padding: 0 5px 0 0">
                        <input tabindex="0" id="code" name="code"
                               aria-invalid="<#if messagesPerField.existsError('registerCode')>true</#if>"
                               type="text" class="${properties.kcInputClass!}"
                               autocomplete="one-time-code"/>
                        <#if messagesPerField.existsError('registerCode')>
                            <span id="input-error-code" class="${properties.kcInputErrorMessageClass!}" aria-live="polite">
                                ${kcSanitize(messagesPerField.get('registerCode'))?no_esc}
                            </span>
                        </#if>
                    </div>
                    <div class="col-xs-4" style="padding: 0 0 0 5px">
                        <input tabindex="0" style="height: 36px"
                               class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonBlockClass!} ${properties.kcButtonLargeClass!}"
                               v-model="sendButtonText" :disabled='sendButtonText !== initSendButtonText'
                               v-on:click="sendVerificationCode()"
                               type="button" value="${msg("sendVerificationCode")}"/>
                    </div>
                </div>
                </#if>
            <#if !hideEmail??>
            </div>
            </#if>
            </#if>

            <#-- 姓名字段（公共） -->
            <#-- 姓名字段（公共） -->
            <#if !hideName??>
            <div class="${properties.kcFormGroupClass!}">
                <div class="${properties.kcLabelWrapperClass!}">
                    <label for="firstName" class="${properties.kcLabelClass!}">${msg("firstName")}</label>
                </div>
                <div class="${properties.kcInputWrapperClass!}">
                    <input type="text" id="firstName" class="${properties.kcInputClass!}" name="firstName"
                           value="${(register.formData.firstName!'')}"
                           aria-invalid="<#if messagesPerField.existsError('firstName')>true</#if>"
                    />

                    <#if messagesPerField.existsError('firstName')>
                        <span id="input-error-firstname" class="${properties.kcInputErrorMessageClass!}" aria-live="polite">
                            ${kcSanitize(messagesPerField.get('firstName'))?no_esc}
                        </span>
                    </#if>
                </div>
            </div>

            <div class="${properties.kcFormGroupClass!}">
                <div class="${properties.kcLabelWrapperClass!}">
                    <label for="lastName" class="${properties.kcLabelClass!}">${msg("lastName")}</label>
                </div>
                <div class="${properties.kcInputWrapperClass!}">
                    <input type="text" id="lastName" class="${properties.kcInputClass!}" name="lastName"
                           value="${(register.formData.lastName!'')}"
                           aria-invalid="<#if messagesPerField.existsError('lastName')>true</#if>"
                    />

                    <#if messagesPerField.existsError('lastName')>
                        <span id="input-error-lastname" class="${properties.kcInputErrorMessageClass!}" aria-live="polite">
                            ${kcSanitize(messagesPerField.get('lastName'))?no_esc}
                        </span>
                    </#if>
                </div>
            </div>
            </#if>
            
            <#-- 密码字段（公共） -->
            <#-- 密码字段（公共） -->
            <#if passwordRequired??>
                <div class="${properties.kcFormGroupClass!}">
                    <div class="${properties.kcLabelWrapperClass!}">
                        <label for="password" class="${properties.kcLabelClass!}">${msg("password")}</label>
                    </div>
                    <div class="${properties.kcInputWrapperClass!}">
                        <input type="password" id="password" class="${properties.kcInputClass!}" name="password"
                               autocomplete="new-password"
                               aria-invalid="<#if messagesPerField.existsError('password','password-confirm')>true</#if>"
                        />

                        <#if messagesPerField.existsError('password')>
                            <span id="input-error-password" class="${properties.kcInputErrorMessageClass!}" aria-live="polite">
                                ${kcSanitize(messagesPerField.get('password'))?no_esc}
                            </span>
                        </#if>
                    </div>
                </div>

                <div class="${properties.kcFormGroupClass!}">
                    <div class="${properties.kcLabelWrapperClass!}">
                        <label for="password-confirm"
                               class="${properties.kcLabelClass!}">${msg("passwordConfirm")}</label>
                    </div>
                    <div class="${properties.kcInputWrapperClass!}">
                        <input type="password" id="password-confirm" class="${properties.kcInputClass!}"
                               name="password-confirm"
                               aria-invalid="<#if messagesPerField.existsError('password-confirm')>true</#if>"
                        />

                        <#if messagesPerField.existsError('password-confirm')>
                            <span id="input-error-password-confirm" class="${properties.kcInputErrorMessageClass!}" aria-live="polite">
                                ${kcSanitize(messagesPerField.get('password-confirm'))?no_esc}
                            </span>
                        </#if>
                    </div>
                </div>
            </#if>

            <#-- reCAPTCHA（公共） -->
            <#-- reCAPTCHA（公共） -->
            <#if recaptchaRequired??>
                <div class="form-group">
                    <div class="${properties.kcInputWrapperClass!}">
                        <div class="g-recaptcha" data-size="compact" data-sitekey="${recaptchaSiteKey}"></div>
                    </div>
                </div>
            </#if>

            <div class="${properties.kcFormGroupClass!}">
                <div id="kc-form-options" class="${properties.kcFormOptionsClass!}">
                    <div class="${properties.kcFormOptionsWrapperClass!}">
                        <span><a href="${url.loginUrl}">${kcSanitize(msg("backToLogin"))?no_esc}</a></span>
                    </div>
                </div>

                <div id="kc-form-buttons" class="${properties.kcFormButtonsClass!}">
                    <input class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonBlockClass!} ${properties.kcButtonLargeClass!}" type="submit" value="${msg("doRegister")}"/>
                </div>
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
                        <#-- 根据之前提交的数据决定显示哪个Tab -->
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
                            req(phoneNumber);
                        }
                    },
                    watch: {
                        phoneRegister: function(newVal, oldVal) {
                            // 只在用户手动切换时清空输入框（不是页面加载时）
                            if (oldVal !== undefined) {
                                // 清空错误信息
                                this.errorMessage = '';
                                // 清空输入框
                                if (newVal) {
                                    // 切换到手机号注册
                                    const emailField = document.getElementById('email');
                                    if (emailField) emailField.value = '';
                                } else {
                                    // 切换到邮箱注册  
                                    const phoneField = document.getElementById('phoneNumber');
                                    if (phoneField) phoneField.value = '';
                                    const codeField = document.getElementById('code');
                                    if (codeField) codeField.value = '';
                                }
                            }
                        }
                    }
                });
            </script>
        </#if>
    </#if>
</@layout.registrationLayout>