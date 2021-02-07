package cordova.plugin.livepersonswift;

import android.app.Activity;
import android.content.Context;
import android.util.Log;

import com.liveperson.infra.BadArgumentException;
import com.liveperson.infra.CampaignInfo;
import com.liveperson.infra.ConversationViewParams;
import com.liveperson.infra.ICallback;
import com.liveperson.infra.InitLivePersonProperties;
import com.liveperson.infra.MonitoringInitParams;
import com.liveperson.infra.auth.LPAuthenticationParams;
import com.liveperson.infra.auth.LPAuthenticationType;
import com.liveperson.infra.callbacks.InitLivePersonCallBack;
import com.liveperson.infra.model.LPWelcomeMessage;
import com.liveperson.infra.model.MessageOption;
import com.liveperson.messaging.sdk.api.LivePerson;
import com.liveperson.messaging.sdk.api.model.ConsumerProfile;
import com.liveperson.monitoring.model.EngagementDetails;
import com.liveperson.monitoring.model.LPMonitoringIdentity;
import com.liveperson.monitoring.sdk.MonitoringParams;
import com.liveperson.monitoring.sdk.api.LivepersonMonitoring;
import com.liveperson.monitoring.sdk.callbacks.EngagementCallback;
import com.liveperson.monitoring.sdk.callbacks.MonitoringErrorType;
import com.liveperson.monitoring.sdk.responses.LPEngagementResponse;

import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;
import org.json.JSONArray;

import java.util.Collections;
import java.util.List;

public class LpMessagingWrapper {

    private static final String TAG = "LivePersonPlugin";

    private static final String BRAND_ID = "70387001";
    private static final String APP_INSTALLATION_ID = "81be1920-b6cb-450d-87eb-d21b9c90e62f";

    private static final String APP_ID = "com.quantummaterialscorp.healthid"; //It's the applicationId, which will be used for FCM.
    private static final String ISSUER = "QMC_Android";

    public static void initializeLPMessagingSDK(Context context, Listener listener) {

        MonitoringInitParams monitoringInitParams = new MonitoringInitParams(APP_INSTALLATION_ID);
        LivePerson.initialize(context, new InitLivePersonProperties(BRAND_ID, APP_ID, monitoringInitParams, new InitLivePersonCallBack() {
            @Override
            public void onInitSucceed() {
                listener.onSuccess();
            }

            @Override
            public void onInitFailed(Exception e) {
                listener.onError("Failed to initialize LP SDK.");
            }
        }));
    }

    public static void getEngagement(Context context, JSONArray entryPoints, GetEngagementListener listener) {

        LivePerson.resolveConversation();
        LPMonitoringIdentity identity = new LPMonitoringIdentity("", ISSUER);
        MonitoringParams params = new MonitoringParams("", entryPoints, new JSONArray());
        LivepersonMonitoring.getEngagement(context, Collections.singletonList(identity), params, new EngagementCallback() {
            @Override
            public void onSuccess(@NotNull LPEngagementResponse response) {
                if (response.getEngagementDetailsList() != null) {
                    Log.d(TAG, "get engagement response: " + response);
                    listener.onSuccess(response);
                }
            }

            @Override
            public void onError(@NotNull MonitoringErrorType monitoringErrorType, @Nullable Exception e) {
                listener.onError("Failed to get engagement.");
                Log.e(TAG, "get engagement error", e);
            }
        });
    }

    public static void showConversation(Activity activity, String firstName, String welcomeMessage, List<MessageOption> optionItems, LPEngagementResponse response, Listener listener) {
        try {
            EngagementDetails detail = response.getEngagementDetailsList().get(0);

            CampaignInfo campaignInfo = new CampaignInfo(Long.parseLong(detail.getCampaignId()),
                    Long.parseLong(detail.getEngagementId()), detail.getContextId(),
                    response.getSessionId(), response.getVisitorId());

            ConversationViewParams conversationViewParams = new ConversationViewParams()
                    .setCampaignInfo(campaignInfo);

            conversationViewParams.setLpWelcomeMessage(getWelcomeMessage(welcomeMessage, optionItems));
            setUserProfile(firstName);
            LivePerson.showConversation(activity, new LPAuthenticationParams(LPAuthenticationType.SIGN_UP), conversationViewParams);
            listener.onSuccess();
        } catch (BadArgumentException e) {
            listener.onError("BadArgumentException");
            Log.e(TAG, "failed to showConversation", e);
        }
    }

    public static void showConversation(Activity activity, String firstName, String welcomeMessage, List<MessageOption> optionItems, Listener listener) {
        ConversationViewParams conversationViewParams = new ConversationViewParams();
        conversationViewParams.setLpWelcomeMessage(getWelcomeMessage(welcomeMessage, optionItems));
        setUserProfile(firstName);
        LivePerson.showConversation(activity, new LPAuthenticationParams(LPAuthenticationType.SIGN_UP), conversationViewParams);
        listener.onSuccess();
    }

    private static LPWelcomeMessage getWelcomeMessage(String welcomeMessage, List<MessageOption> optionItems) {
        LPWelcomeMessage lpWelcomeMessage = new LPWelcomeMessage(welcomeMessage);
        try {
            lpWelcomeMessage.setMessageOptions(optionItems);
        } catch (Exception e) {
            //TODO add error handling.
        }
        lpWelcomeMessage.setNumberOfItemsPerRow(1);
        lpWelcomeMessage.setMessageFrequency(LPWelcomeMessage.MessageFrequency.EVERY_CONVERSATION);
        return lpWelcomeMessage;
    }

    private static void setUserProfile(String firstName) {
        //TODO set user profile below
        ConsumerProfile userProfile = new ConsumerProfile.Builder()
                .setFirstName(firstName)
                .setLastName("")
                .setNickname("")
                .setPhoneNumber("")
                .setAvatarUrl("").build();
        LivePerson.setUserProfile(userProfile);
    }

    public static void registerLPPusher(String deviceToken, Listener listener) {
        LivePerson.registerLPPusher(BRAND_ID, APP_ID, deviceToken, new LPAuthenticationParams(LPAuthenticationType.SIGN_UP), new ICallback<Void, Exception>() {
            @Override
            public void onSuccess(Void aVoid) {
                listener.onSuccess();
            }

            @Override
            public void onError(Exception e) {
                listener.onError("Failed to register pusher");
            }
        });
    }

    public interface Listener {
        void onSuccess();

        void onError(String error);
    }

    public interface GetEngagementListener {
        void onSuccess(LPEngagementResponse response);

        void onError(String error);
    }
}
