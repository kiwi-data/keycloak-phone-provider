package cc.coopersoft.keycloak.phone.providers.sender;

import cc.coopersoft.keycloak.phone.providers.constants.TokenCodeType;
import cc.coopersoft.keycloak.phone.providers.exception.MessageSendException;
import cc.coopersoft.keycloak.phone.providers.spi.MessageSenderService;
import cc.coopersoft.common.OptionalUtils;
import com.aliyun.auth.credentials.Credential;
import com.aliyun.auth.credentials.provider.StaticCredentialProvider;
import com.aliyun.sdk.service.dysmsapi20170525.AsyncClient;
import com.aliyun.sdk.service.dysmsapi20170525.models.SendSmsRequest;
import com.aliyun.sdk.service.dysmsapi20170525.models.SendSmsResponse;
import darabonba.core.client.ClientOverrideConfiguration;
import lombok.extern.slf4j.Slf4j;
import org.jboss.logging.Logger;
import org.keycloak.Config;
import org.keycloak.models.RealmModel;

import java.util.Optional;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.TimeUnit;

@Slf4j
public class AliyunSmsSenderServiceProvider implements MessageSenderService {

  private static final Logger logger = Logger.getLogger(AliyunSmsSenderServiceProvider.class);

  private final Config.Scope config;
  private final RealmModel realm;
  private final AsyncClient client;

  public AliyunSmsSenderServiceProvider(Config.Scope config, RealmModel realm) {
    this.config = config;
    this.realm = realm;
    // Configure Credentials authentication information, including ak, secret, token
    StaticCredentialProvider provider = StaticCredentialProvider.create(Credential.builder()
        .accessKeyId(config.get("key"))
        .accessKeySecret(config.get("secret"))
        .build());

    // Configure the Client
    client = AsyncClient.builder()
        //.httpClient(httpClient) // Use the configured HttpClient, otherwise use the default HttpClient (Apache HttpClient)
        .credentialsProvider(provider)
        //.serviceConfiguration(Configuration.create()) // Service-level configuration
        // Client-level configuration rewrite, can set Endpoint, Http request parameters, etc.
        .overrideConfiguration(
            ClientOverrideConfiguration.create()
                // Endpoint 请参考 https://api.aliyun.com/product/Dysmsapi
                .setEndpointOverride("dysmsapi.aliyuncs.com")
            //.setConnectTimeout(Duration.ofSeconds(30))
        )
        .build();

  }

  @Override
  public void sendSmsMessage(TokenCodeType type, String phoneNumber, String code, int expires, String kind) throws MessageSendException {

    String kindName = OptionalUtils.ofBlank(kind).orElse(type.name().toLowerCase());
    String templateId = Optional.ofNullable(config.get(realm.getName().toLowerCase() + "-" + kindName + "-template"))
        .orElse(config.get(kindName + "-template"));
    logger.info("Send SMS using template: " + templateId + " for realm: " + realm.getName() + ", kind: " + kindName + ", signName: " + config.get("signname"));

    try {
      // Parameter settings for API request
      SendSmsRequest sendSmsRequest = SendSmsRequest.builder()
              .phoneNumbers(phoneNumber)
              .signName(config.get("signname"))
              .templateCode(templateId)
              .templateParam(String.format("{\"code\":\"%s\",\"expires\":\"%s\"}",code,expires / 60))
              // Request-level configuration rewrite, can set Http request parameters, etc.
              // .requestConfiguration(RequestConfiguration.create().setHttpHeaders(new HttpHeaders()))
              .build();

      // Asynchronously get the return value of the API request
      SendSmsResponse response = client.sendSms(sendSmsRequest).get(10, TimeUnit.SECONDS);
      String bizCode = response.getBody().getCode(); // 阿里云业务码，OK 才算成功
      if (!"OK".equalsIgnoreCase(bizCode)) {
        throw new RuntimeException("Aliyun SMS failed: code=" + bizCode
                + ", message=" + response.getBody().getMessage()
                + ", requestId=" + response.getBody().getRequestId());
      }
      logger.infof("Send SMS ok. requestId=%s bizId=%s",
              response.getBody().getRequestId(), response.getBody().getBizId());
    }catch (Exception e){
      logger.error("Send SMS message failed!", e);
    }
  }

  @Override
  public void close() {
    client.close();
  }
}
