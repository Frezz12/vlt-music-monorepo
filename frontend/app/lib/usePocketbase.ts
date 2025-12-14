import PocketBase from "pocketbase";
import { type TypedPocketBase, type UsersRecord } from "./pocketbase-types";
import { computed, onUnmounted, reactive, ref, watch } from "vue";

const pbClient = new PocketBase("http://localhost:8090") as TypedPocketBase;

pbClient.autoCancellation(false)

// const userId = ref<string>("")

const authStore = reactive({
  isSuperuser: pbClient.authStore.isSuperuser,
  isValid: pbClient.authStore.isValid,
  record: pbClient.authStore.record,
  token: pbClient.authStore.token,
});

const unsub = pbClient.authStore.onChange((newToken, newRecord) => {
  authStore.isSuperuser = pbClient.authStore.isSuperuser;
  authStore.isValid = pbClient.authStore.isValid;
  authStore.record = newRecord;
  authStore.token = newToken;
});


export const usePocketBase = () => pbClient;

export const useAuthenticated = () => {
  const auth = useAuth();

  watch(auth.isValid, () => {
    if (auth.isValid.value) {
      return
    }
    navigateTo('/auth/login');
  })
};

export const useAuth = () => {
  const pb = usePocketBase();

  const loading = ref(false);
  const error = ref<string | null>(null);

  const logout = async () => {
    pb.authStore.clear();
  };

  onUnmounted(unsub);

  const authUserWithPassword = async (credentials: {
    email: string;
    password: string;
  }) => {
    try {
      loading.value = true;
      error.value = null;
      await pb
        .collection("users")
        .authWithPassword(credentials.email, credentials.password);
    } catch (err) {
      error.value = (err as Error).message;
    } finally {
      loading.value = false;
    }
  };

  const register = async (data: {
    nikname: string,
    email: string,
    password: string,
    confirmPassword: string,
    refID: string,
  }) => {
    try {
      loading.value = true
      error.value = null;

      const reqData = {
        "nikname": data.nikname,
        "email": data.email,
        "balance": 0,
        "bonus_balance": 1000,
        "ref_code": data.refID || '',
        "password": data.password,
        "passwordConfirm": data.confirmPassword
      }

      await pb.collection('users').create(reqData)

      if (data.refID) {
        const refUser = await pb.collection('users').getOne(data.refID)
        console.log(refUser)

        await pb.collection('users').update(refUser.id, {
          'bonus_balance': refUser.bonus_balance + 1000
        })
      }

      await authUserWithPassword({
        email: reqData.email,
        password: reqData.password
      })

      await navigateTo('/')
    } catch (err) {
      error.value = (err as Error).message;
    } finally {
      loading.value = false;
    }
  }

  const authWithOAuth2 = async (provider: string) => {
    try {
      loading.value = true;
      error.value = null;
      await pb.collection("users").authWithOAuth2({
        provider: provider,
      });
    } catch (err) {
      error.value = (err as Error).message;
    } finally {
      loading.value = false;
    }
  };

  const listAuthMethods = async () => {
    const pb = usePocketBase();

    return pb.collection("users").listAuthMethods();
  };

  return {
    isSuperuser: computed(() => authStore.isSuperuser),
    isValid: computed(() => authStore.isValid),
    record: computed(() => authStore.record),
    token: computed(() => authStore.token),
    logout,
    authUserWithPassword,
    register,
    authWithOAuth2,
    listAuthMethods,
    loading,
    error,
  };
};
