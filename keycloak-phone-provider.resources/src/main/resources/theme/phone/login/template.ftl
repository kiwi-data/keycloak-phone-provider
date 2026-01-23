<#macro registrationLayout bodyClass="" displayInfo=false displayMessage=true displayRequiredFields=false showAnotherWayIfPresent=true>
<!DOCTYPE html>
<html class="${properties.kcHtmlClass!}">
<head>
    <meta charset="utf-8">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="robots" content="noindex, nofollow">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">

    <#if properties.meta?has_content>
        <#list properties.meta?split(' ') as meta>
            <meta name="${meta?split('==')[0]}" content="${meta?split('==')[1]}"/>
        </#list>
    </#if>
    
    <title>${msg("loginTitle",(realm.displayName!''))}</title>
    <link rel="icon" type="image/svg+xml" href="${url.resourcesPath}/img/favicon.svg" />
    
    <#if properties.stylesCommon?has_content>
        <#list properties.stylesCommon?split(' ') as style>
            <link href="${url.resourcesCommonPath}/${style}" rel="stylesheet" />
        </#list>
    </#if>
    <#if properties.styles?has_content>
        <#list properties.styles?split(' ') as style>
            <link href="${url.resourcesPath}/${style}" rel="stylesheet" />
        </#list>
    </#if>
    
    <!-- Protocols Custom Styles -->
    <link href="${url.resourcesPath}/css/protocols.css" rel="stylesheet" />
    
    <#if properties.scripts?has_content>
        <#list properties.scripts?split(' ') as script>
            <script src="${url.resourcesPath}/${script}" type="text/javascript"></script>
        </#list>
    </#if>
    <#if scripts??>
        <#list scripts as script>
            <script src="${script}" type="text/javascript"></script>
        </#list>
    </#if>
</head>
<body>
    <div class="protocols-container">
        <!-- Header with Logo -->
        <div class="protocols-header">
            <img src="${url.resourcesPath}/img/favicon.svg" alt="Protocols" class="protocols-logo" />
            <span class="protocols-brand">Protocols</span>
        </div>
        
        <!-- Main Content -->
        <div class="protocols-main">
            <div class="protocols-card">
                <!-- Title Section -->
                <div class="protocols-title-section">
                    <h1 class="protocols-title"><#nested "header"></h1>
                    <img src="${url.resourcesPath}/img/favicon.svg" alt="" class="protocols-title-icon" />
                </div>
                
                <#if realm.internationalizationEnabled  && locale.supported?size gt 1>
                    <div class="protocols-locale">
                        <select id="locale-select" onchange="if (this.value) window.location.href = this.value;">
                            <#list locale.supported as l>
                                <option value="${l.url}" <#if l.label == locale.current>selected</#if>>${l.label}</option>
                            </#list>
                        </select>
                    </div>
                </#if>

                <#-- Display global messages -->
                <#if displayMessage && message?has_content && (message.type != 'warning' || !isAppInitiatedAction??)>
                    <div class="protocols-alert <#if message.type = 'success'>protocols-alert-success<#elseif message.type = 'warning'>protocols-alert-warning<#elseif message.type = 'error'>protocols-alert-error<#else>protocols-alert-info</#if>">
                        ${kcSanitize(message.summary)?no_esc}
                    </div>
                </#if>

                <#-- Social Providers Section -->
                <#nested "socialProviders">

                <#-- Form Section -->
                <#nested "form">

                <#-- Info Section -->
                <#if displayInfo>
                    <div class="protocols-footer">
                        <#nested "info">
                    </div>
                </#if>
                
                <!-- Terms and Privacy -->
                <div class="protocols-terms">
                    By continuing, you are agreeing to<br>
                    Protocols' <a href="javascript:void(0)" onclick="openPolicyModal('terms')">Terms of Service</a>, 
                    <a href="javascript:void(0)" onclick="openPolicyModal('privacy')">Privacy Policy</a> and 
                    <a href="javascript:void(0)" onclick="openPolicyModal('cookie')">Cookie Policy</a>.
                </div>
            </div>
        </div>
    </div>
    
    <!-- Policy Modals -->
    <div id="policy-modal-overlay" class="policy-modal-overlay" onclick="closePolicyModal()">
        <div class="policy-modal" onclick="event.stopPropagation()">
            <div class="policy-modal-header">
                <h2 id="policy-modal-title" class="policy-modal-title"></h2>
                <button class="policy-modal-close" onclick="closePolicyModal()">&times;</button>
            </div>
            <div id="policy-modal-content" class="policy-modal-content"></div>
        </div>
    </div>
    
    <script type="text/javascript">
        var policyContent = {
            terms: {
                title: 'Terms of Service',
                date: '1/22/2026',
                content: '<p class="policy-text">By accessing or using this website, you agree to be bound by these Terms of Service.</p>' +
                    '<h3 class="policy-heading">Eligibility</h3>' +
                    '<p class="policy-text"><strong>You must be of legal age in your jurisdiction to register and participate.</strong></p>' +
                    '<h3 class="policy-heading">Use of Website</h3>' +
                    '<p class="policy-text">You agree not to misuse this website or engage in unlawful activity. You must provide accurate information when registering.</p>' +
                    '<h3 class="policy-heading">Event Participation</h3>' +
                    '<p class="policy-text">We reserve the right to modify, postpone, or cancel the event.</p>' +
                    '<h3 class="policy-heading">Intellectual Property</h3>' +
                    '<p class="policy-text">All content on this website, including logos, text, and media, is protected by intellectual property rights and may not be used without authorization.</p>' +
                    '<h3 class="policy-heading">Disclaimer and Limitation of Liability</h3>' +
                    '<p class="policy-text">The website and event are provided "as is." To the maximum extent permitted by law, we disclaim all liability for damages arising from your use of the website or participation in the event.</p>' +
                    '<h3 class="policy-heading">Governing Law</h3>' +
                    '<p class="policy-text">These Terms shall be governed by and construed in accordance with the laws of the United States, except as otherwise required by applicable law.</p>'
            },
            privacy: {
                title: 'Privacy Policy',
                date: '1/22/2026',
                content: '<p class="policy-text">This Privacy Policy describes how we collect, use, and disclose information in connection with your use of this website.</p>' +
                    '<h3 class="policy-heading">Information We Collect</h3>' +
                    '<p class="policy-text">We may collect:</p>' +
                    '<ul class="policy-list">' +
                    '<li>Personal information you provide, such as your name, email address, and other registration details.</li>' +
                    '<li>Technical data, including IP address, browser type, and site usage information.</li>' +
                    '</ul>' +
                    '<h3 class="policy-heading">Use of Information</h3>' +
                    '<p class="policy-text">We use your information to:</p>' +
                    '<ul class="policy-list">' +
                    '<li>Process event registrations and communications.</li>' +
                    '<li>Improve the functionality and security of our website.</li>' +
                    '<li>Comply with legal and regulatory obligations.</li>' +
                    '</ul>' +
                    '<h3 class="policy-heading">Disclosure of Information</h3>' +
                    '<p class="policy-text">We do not sell personal data. Information may be disclosed to service providers acting on our behalf, or where required by law.</p>' +
                    '<h3 class="policy-heading">Data Retention and Security</h3>' +
                    '<p class="policy-text">We retain your information only as long as necessary for event purposes and take reasonable measures to safeguard it.</p>' +
                    '<h3 class="policy-heading">Your Rights</h3>' +
                    '<p class="policy-text">You may request access to, correction of, or deletion of your personal data. Contact us at <a href="mailto:dev@funcity.org" class="policy-link">dev@funcity.org</a> for such requests.</p>'
            },
            cookie: {
                title: 'Cookie Policy',
                date: '1/22/2026',
                content: '<p class="policy-text">This Cookie Policy explains how cookies are used on this website.</p>' +
                    '<h3 class="policy-heading">What Are Cookies</h3>' +
                    '<p class="policy-text">Cookies are small text files stored on your device when you visit our website.</p>' +
                    '<h3 class="policy-heading">Types of Cookies We Use</h3>' +
                    '<ul class="policy-list">' +
                    '<li><strong>Strictly Necessary Cookies:</strong> Essential for website operation and registration functions.</li>' +
                    '<li><strong>Performance and Analytics Cookies:</strong> Collect data on usage to help us improve services.</li>' +
                    '<li><strong>Preference Cookies:</strong> Store user settings and preferences.</li>' +
                    '</ul>' +
                    '<h3 class="policy-heading">Third-Party Cookies</h3>' +
                    '<p class="policy-text">We may use third-party services (e.g., analytics providers) that set their own cookies.</p>' +
                    '<h3 class="policy-heading">Managing Cookies</h3>' +
                    '<p class="policy-text">You may disable or restrict cookies through your browser settings. Please note that disabling certain cookies may affect website functionality.</p>'
            }
        };
        
        function openPolicyModal(type) {
            var policy = policyContent[type];
            if (!policy) return;
            
            document.getElementById('policy-modal-title').innerHTML = policy.title + '<span class="policy-date">' + policy.date + '</span>';
            document.getElementById('policy-modal-content').innerHTML = policy.content;
            document.getElementById('policy-modal-overlay').classList.add('active');
            document.body.style.overflow = 'hidden';
        }
        
        function closePolicyModal() {
            document.getElementById('policy-modal-overlay').classList.remove('active');
            document.body.style.overflow = '';
        }
        
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                closePolicyModal();
            }
        });
    </script>
</body>
</html>
</#macro>
