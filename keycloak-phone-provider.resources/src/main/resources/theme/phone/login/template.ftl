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
            </div>
        </div>
    </div>
</body>
</html>
</#macro>
