package cordova.plugin.livepersonswift;

import android.content.Context;
import android.util.Log;

import com.google.firebase.messaging.RemoteMessage;
import com.liveperson.infra.model.MessageOption;
import com.liveperson.infra.model.PushMessage;
import com.liveperson.messaging.sdk.api.LivePerson;
import com.liveperson.messaging.sdk.api.callbacks.LogoutLivePersonCallback;
import com.liveperson.monitoring.sdk.responses.LPEngagementResponse;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;

import java.util.Collections;
import java.util.List;
import java.util.Map;

/**
 * This class echoes a string called from JavaScript.
 */
public class livepersonswift extends CordovaPlugin {

    private static final String TAG = "LivePersonPlugin";

    //    QMC
    private static String BRAND_ID = "70387001";
    private static String APP_INSTALLATION_ID = "81be1920-b6cb-450d-87eb-d21b9c90e62f";

    private String APP_ID = "com.quantummaterialscorp.healthid"; //It's the applicationId, which will be used for FCM.
    private String ISSUER = "QMC_Android";
    private String firstName;
    private String LPResponse;
    private String selectedLanguage;
    LPEngagementResponse maintainResponse;

    private JSONArray entryPoints;

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("instantiateLPMessagingSDK")) {
             firstName = args.getString(0);
            // BRAND_ID = args.getString(1); //TODO question: is it possible that we change the BRAND_ID? Can we hardcode it or no.
            // APP_INSTALLATION_ID = args.getString(2); //TODO save question as BRAND_ID
            // APP_ID = args.getString(3);//TODO save question as BRAND_ID
            // ISSUER = args.getString(4);//TODO save question as BRAND_ID
//             try {
                // JSONObject customEntryPoints = new JSONObject();
                // customEntryPoints.put("entryPoint", args.getString(5));
                // Log.d("Recieved Custom", customEntryPoints.toString());
                // customEntryPoints.put("entryPointEnvironment", args.getString(6));
                // customEntryPoints.put("entryPointCountry", args.getString(7));
                // customEntryPoints.put("entryPointlanguage", args.getString(8));
                // Log.d("Recieved Custom", customEntryPoints.toString());

                // entryPoints = new JSONArray();
                // entryPoints.put(args.getString(5))
                //         .put(args.getString(6))
                //         .put(args.getString(7))
                //         .put(args.getString(8));

                // entryPoints = new JSONArray();
                // entryPoints.put("android-default")
                //         .put("dev")
                //         .put("us")
                //         .put("en");

                this.ConnectToBot(firstName, callbackContext);

//             } catch (JSONException e) {
//                 Log.d("Recieved Custom", e.toString());
//             }

            return true;
        }
        else if(action.equals("ConnectToBot")){
          entryPoints = new JSONArray();
            selectedLanguage = args.getString(2);
            Log.d("received Language", selectedLanguage);
          entryPoints.put(args.get(0))
            .put(args.get(1))
            .put(args.get(2))
            .put(args.get(3));
          getEngagement(callbackContext);
          return true;
        }
        else
        {
            
            showConversation(firstName,maintainResponse,callbackContext);
            return true;
        }
        
    }

    private void coolMethod(String message, CallbackContext callbackContext) {
        if (message != null && message.length() > 0) {
            callbackContext.success(message);
        } else {
            callbackContext.error("Expected one non-empty string argument.");
        }
    }

    private void ConnectToBot(String message, CallbackContext callbackContext) {
        if (message != null && message.length() > 0) {
            callbackContext.success(message);

            initLpSDK(callbackContext);
            /*Context context = cordova.getActivity().getApplicationContext();
            Intent intent = new Intent(context, cordova.plugin.LivePersonPlugin.LivePersonChatRoom.class);
            this.cordova.getActivity().startActivity(intent);*/
        } else {
            callbackContext.error("Expected one non-empty string argument.");
        }
    }

    public void initLpSDK(CallbackContext callbackContext) {
        Context context = cordova.getActivity().getApplicationContext();
        LpMessagingWrapper.initializeLPMessagingSDK(context, new LpMessagingWrapper.Listener() {
            @Override
            public void onSuccess() {
                callbackContext.success("pre_engagement");
                Log.d(TAG, "pre_engagement");
//                getEngagement(callbackContext); //TODO remove this line if want to call it from Ionic.
//                 showConversationWithoutEngagement(firstName, callbackContext);
            }

            @Override
            public void onError(String error) {
                callbackContext.error(error);
                Log.e(TAG, error);
            }
        });
    }

    public void getEngagement(CallbackContext callbackContext) {
        Context context = cordova.getActivity().getApplicationContext();
        Log.d(TAG, "getEngagement with entry points: " + entryPoints);
        LpMessagingWrapper.getEngagement(context, entryPoints, new LpMessagingWrapper.GetEngagementListener() {
            @Override
            public void onSuccess(LPEngagementResponse response) {
                callbackContext.success("post Engagement");
                maintainResponse = response;
               // showConversation(firstName, response, callbackContext); //TODO remove this line if want to call it from Ionic.
            }

            @Override
            public void onError(String error) {
                callbackContext.error(error);
                Log.e(TAG, error);
            }
        });
    }

    public void showConversation(String firstName, LPEngagementResponse response, CallbackContext callbackContext) {
        //TODO Needs to set welcome message and optionItems from Ionic.
        String welcomeMessage_based_on_language = null;
        String display_text_value = null;
        if (selectedLanguage.equals("en")) {
            welcomeMessage_based_on_language = "Hi, I'm BELLA, your automated health assistant. I'll be guiding you through your at-home COVID-19 test.";
            display_text_value= "Start";
        } else {
            welcomeMessage_based_on_language = "Hola, soy BELLA, tu asistente de salud automatizado. Lo guiaré a través de su prueba de COVID-19 en casa.";
            display_text_value= "Comienzo";
        }
        String welcomeMessage = welcomeMessage_based_on_language;
        List<MessageOption> optionItems = Collections.singletonList(new MessageOption(display_text_value, display_text_value));
        LpMessagingWrapper.showConversation(cordova.getActivity(), firstName, welcomeMessage, optionItems, response, new LpMessagingWrapper.Listener() {
            @Override
            public void onSuccess() {
                callbackContext.success();
                //TODO register pusher either here or in Ionic.
            }

            @Override
            public void onError(String error) {
                callbackContext.error(error);
                Log.e(TAG, error);
            }
        });
    }

    public void showConversationWithoutEngagement(String firstName, CallbackContext callbackContext) {
        //TODO Needs to set welcome message and optionItems from Ionic.
        String welcomeMessage = "Hi, I'm BELLA, your automated health assistant. I'll be guiding you through your at-home COVID-19 test.";
        List<MessageOption> optionItems = Collections.singletonList(new MessageOption("Start", "Start"));

        LpMessagingWrapper.showConversation(cordova.getActivity(), firstName, welcomeMessage, optionItems, new LpMessagingWrapper.Listener() {
            @Override
            public void onSuccess() {
                callbackContext.success();
                //TODO register pusher either here or in Ionic.
            }

            @Override
            public void onError(String error) {
                callbackContext.error(error);
                Log.e(TAG, error);
            }
        });
    }

    public void registerLpPusher(String deviceToken, CallbackContext callbackContext) {
        LpMessagingWrapper.registerLPPusher(deviceToken, new LpMessagingWrapper.Listener() {
            @Override
            public void onSuccess() {
                callbackContext.success();
            }

            @Override
            public void onError(String error) {
                callbackContext.error(error);
                Log.e(TAG, error);
            }
        });
    }

    /**
     * This is an example of how push notification works with SDK.
     * TODO The method below should show a notification banner. If the way Ionic work is different, you can simply ignore/delete this method.
     */
    private void showPushNotification(Context context, PushMessage pushMessage) {

    }

    /**
     * Logout the SDK. Device will be unregistered from LP pusher.
     * All cached data will be deleted.
     */
    public void logout(CallbackContext callbackContext) {
        Context context = cordova.getActivity().getApplicationContext();
        LivePerson.logOut(context, BRAND_ID, APP_ID, new LogoutLivePersonCallback() {
            @Override
            public void onLogoutSucceed() {
                callbackContext.success("logout succeed");
            }

            @Override
            public void onLogoutFailed() {
                callbackContext.error("Failed to logout");
            }
        });
    }

    /**
     * Clear conversation history. (Only closed conversation can be cleared)
     */
    public void clearHistory() {
        LivePerson.clearHistory();
    }

    public void resolveConversation() {
        LivePerson.resolveConversation();
    }

    /**
     * Pass the data message received from {@link com.gae.scaffolder.plugin.MyFirebaseMessagingService#onMessageReceived(RemoteMessage)}
     * The message push notification received is
     * <br/>
     * <b>{payload={"badge":1,"sequence":8,"conversationId":"3e951ec7-a450-4a24-8058-b19cc9881c67","brandId":"61895277","backendService":"ams","originatorId":"61895277.1197179432","dialogId":"3e951ec7-a450-4a24-8058-b19cc9881c67"}, message=Mask Push Notification}</b>
     * <br/>
     * <p>
     * {@link LivePerson#handlePushMessage(Context, Map, String, boolean)} parses it to an {@link PushMessage} object.
     * TODO call this method when receive push notification.
     *
     * @param remoteMessageData It's the data message received from FCM. The value is RemoteMessage.getData().
     */
    public void showPushNotification(Map<String, String> remoteMessageData) {
        Context context = cordova.getActivity().getApplicationContext();
        PushMessage message = LivePerson.handlePushMessage(context, remoteMessageData, BRAND_ID, false);
        if (message != null) {
            showPushNotification(context, message);
        }
    }
}
