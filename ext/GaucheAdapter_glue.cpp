#include "GaucheAdapter_glue.h"

ScmClass *TwsClientClass;

static void tws_client_print(ScmObj obj, ScmPort *out, ScmWriteContext *ctx) {
    GaucheAdapter *a = TWS_CLIENT_UNBOX(obj);
    Scm_Printf(out, "#<tws-client %p>", (void*)obj);
}

static void tws_client_cleanup(ScmObj obj) {
    GaucheAdapter *a;
    a = TWS_CLIENT_UNBOX(obj);
    delete a;
}

////////////////

ScmClass *TwsContractClass;

static void tws_contract_print(ScmObj obj, ScmPort *out, ScmWriteContext *ctx) {
    Contract *a = TWS_CONTRACT_UNBOX(obj);
    Scm_Printf(out, "#<tws-contract %p>", (void*)obj);
}

static void tws_contract_cleanup(ScmObj obj) {
    Contract *a;
    a = TWS_CONTRACT_UNBOX(obj);
    delete a;
}

////////////////

ScmClass *TwsOrderClass;

static void tws_order_print(ScmObj obj, ScmPort *out, ScmWriteContext *ctx) {
    Order *a = TWS_ORDER_UNBOX(obj);
    Scm_Printf(out, "#<tws-order %p>", (void*)obj);
}

static void tws_order_cleanup(ScmObj obj) {
    Order *a;
    a = TWS_ORDER_UNBOX(obj);
    delete a;
}

/////////////////////////

extern void Scm_Init_tws_client_lib(ScmModule*);

void Scm_Init_tws_client() {
    ScmModule *mod;

    Scm_Printf(SCM_CURERR, "%s\n", __FUNCTION__);

    SCM_INIT_EXTENSION(tws_client);

    mod = SCM_MODULE(SCM_FIND_MODULE("ext.tws-client", TRUE));

    TwsClientClass =
        Scm_MakeForeignPointerClass(mod, "<tws-client>",
                                    tws_client_print,
                                    tws_client_cleanup,
                                    SCM_FOREIGN_POINTER_KEEP_IDENTITY|SCM_FOREIGN_POINTER_MAP_NULL);

    TwsContractClass =
        Scm_MakeForeignPointerClass(mod, "<tws-contract>",
                                    tws_contract_print,
                                    tws_contract_cleanup,
                                    SCM_FOREIGN_POINTER_KEEP_IDENTITY|SCM_FOREIGN_POINTER_MAP_NULL);

    TwsOrderClass =
        Scm_MakeForeignPointerClass(mod, "<tws-order>",
                                    tws_order_print,
                                    tws_order_cleanup,
                                    SCM_FOREIGN_POINTER_KEEP_IDENTITY|SCM_FOREIGN_POINTER_MAP_NULL);

    Scm_Init_tws_client_lib(mod);
}


// Local Variables:
// c-basic-offset: 4
// End:
