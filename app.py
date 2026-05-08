import streamlit as st
from datetime import date, datetime
import database as db

# ---------- Init ----------
db.init_db()

SHARED_CATEGORIES = ["水费", "电费", "煤气费", "物业费", "网络费", "房租"]
PERSONAL_CATEGORIES = ["购物", "餐饮", "交通", "医疗", "娱乐", "其他"]

if "page" not in st.session_state:
    st.session_state.page = "记录支出"

# ---------- Sidebar ----------
st.sidebar.title("家庭记账本")

pages = {p: st.sidebar.button(p, use_container_width=True) for p in ["记录支出", "支出列表", "概览", "结清管理"]}
for name, clicked in pages.items():
    if clicked:
        st.session_state.page = name

st.sidebar.divider()
st.sidebar.caption("数据存储在本地 SQLite 数据库中")

# ---------- Helpers ----------
def show_settlement_result(sid):
    s = db.get_settlements()
    info = next((x for x in s if x["id"] == sid), None)
    if not info:
        return
    st.success("结清完成！")
    net = info["net_transfer"]
    if net > 0:
        st.info(f"老婆需转账给**我**：**{net:.2f}** 元")
    elif net < 0:
        st.info(f"我需要转账给**老婆**：**{abs(net):.2f}** 元")
    else:
        st.info("双方持平，无需转账")
    st.caption(f"本次 AA 总额 {info['total_amount']:.2f} 元 | 我垫付 {info['me_paid']:.2f} 元 | 老婆垫付 {info['wife_paid']:.2f} 元")

# ========== 记录支出 ==========
if st.session_state.page == "记录支出":
    st.header("记录一笔支出")

    with st.form("add_expense", clear_on_submit=True):
        col1, col2 = st.columns(2)
        amount = col1.number_input("金额（元）", min_value=0.01, step=0.01, format="%.2f")
        expense_date = col2.date_input("日期", value=date.today())

        is_shared = st.toggle("AA 平摊", value=True)

        cats = SHARED_CATEGORIES if is_shared else PERSONAL_CATEGORIES
        cat_default = SHARED_CATEGORIES[0] if is_shared else PERSONAL_CATEGORIES[0]
        idx = cats.index(cat_default) if cat_default in cats else 0
        category = st.selectbox("类别", cats, index=idx)

        payer = st.radio("支付者", ["我", "老婆"], horizontal=True)

        description = st.text_input("备注（可选）", placeholder=f"如：{category}明细")

        submitted = st.form_submit_button("添加")
        if submitted:
            db.add_expense(amount, category, description, expense_date.isoformat(), payer, is_shared)
            st.toast(f"已添加：{category} {amount:.2f} 元")

# ========== 支出列表 ==========
elif st.session_state.page == "支出列表":
    st.header("支出列表")

    filt = st.radio("筛选", ["全部", "未结清（AA）", "已结清", "个人支出"], horizontal=True, key="list_filter")

    all_expenses = db.get_expenses()
    if filt == "未结清（AA）":
        all_expenses = [e for e in all_expenses if e["is_shared"] and e["settlement_id"] is None]
    elif filt == "已结清":
        all_expenses = [e for e in all_expenses if e["settlement_id"] is not None]
    elif filt == "个人支出":
        all_expenses = [e for e in all_expenses if not e["is_shared"]]

    if not all_expenses:
        st.caption("暂无记录")
    else:
        # Build table rows with actions
        for i, e in enumerate(all_expenses):
            shared_label = "AA" if e["is_shared"] else "个人"
            settled_label = f"结清#{e['settlement_id']}" if e["settlement_id"] else "未结清"
            cols = st.columns([2, 1.5, 1, 1, 1, 1, 1.5])
            cols[0].write(f"**{e['category']}**")
            cols[1].write(f"{e['amount']:.2f} 元")
            cols[2].write(e["payer"])
            cols[3].write(shared_label)
            cols[4].write(settled_label)
            cols[5].write(e["expense_date"])
            if cols[6].button("删除", key=f"del_{e['id']}"):
                db.delete_expense(e["id"])
                st.rerun()

    # Summary stats
    st.divider()
    col1, col2, col3 = st.columns(3)
    all_shared = [e for e in all_expenses if e["is_shared"]]
    col1.metric("AA 总金额", f"{sum(e['amount'] for e in all_shared):.2f} 元")
    col2.metric("我垫付（AA）", f"{sum(e['amount'] for e in all_shared if e['payer'] == '我'):.2f} 元")
    col3.metric("老婆垫付（AA）", f"{sum(e['amount'] for e in all_shared if e['payer'] == '老婆'):.2f} 元")

# ========== 概览 ==========
elif st.session_state.page == "概览":
    st.header("概览")

    unsettled = db.get_unsettled_shared_expenses()

    # Cards
    col1, col2, col3 = st.columns(3)
    total = sum(e["amount"] for e in unsettled)
    me_paid = sum(e["amount"] for e in unsettled if e["payer"] == "我")
    wife_paid = sum(e["amount"] for e in unsettled if e["payer"] == "老婆")
    net = round((me_paid - wife_paid) / 2, 2)

    col1.metric("未结清 AA 总额", f"{total:.2f} 元")
    col2.metric("我垫付", f"{me_paid:.2f} 元")
    col3.metric("老婆垫付", f"{wife_paid:.2f} 元")

    if total > 0:
        st.divider()
        if net > 0:
            st.info(f"目前**老婆需转账给我 {net:.2f} 元**")
        elif net < 0:
            st.info(f"目前**我需要转账给老婆 {abs(net):.2f} 元**")
        else:
            st.info("目前双方持平")

        st.subheader("未结清支出明细")
        for e in unsettled:
            cols = st.columns([2, 1, 1])
            cols[0].write(f"{e['expense_date']} — {e['category']}")
            cols[1].write(f"{e['amount']:.2f} 元")
            cols[2].write(e["payer"])
    else:
        st.caption("暂无未结清的 AA 支出")

    # Recent settlements
    settlements = db.get_settlements()
    if settlements:
        st.divider()
        st.subheader("最近结清记录")
        for s in settlements[:5]:
            with st.expander(f"{s['settlement_date']} — 总额 {s['total_amount']:.2f} 元 | 净转账 {s['net_transfer']:.2f} 元"):
                st.caption(s.get("note") or "无备注")
                for e in db.get_settlement_expenses(s["id"]):
                    st.write(f"- {e['expense_date']} {e['category']} {e['amount']:.2f} 元（{e['payer']}）")

# ========== 结清管理 ==========
elif st.session_state.page == "结清管理":
    st.header("结清管理")

    unsettled = db.get_unsettled_shared_expenses()

    if not unsettled:
        st.caption("暂无未结清的 AA 支出")
    else:
        # Show calculation preview
        total = sum(e["amount"] for e in unsettled)
        me_paid = sum(e["amount"] for e in unsettled if e["payer"] == "我")
        wife_paid = sum(e["amount"] for e in unsettled if e["payer"] == "老婆")
        net = round((me_paid - wife_paid) / 2, 2)

        st.subheader("待结清支出")
        for e in unsettled:
            cols = st.columns([2, 1.5, 1])
            cols[0].write(f"{e['expense_date']} — {e['category']}")
            cols[1].write(f"{e['amount']:.2f} 元")
            cols[2].write(e["payer"])

        st.divider()
        st.subheader("结清计算")
        col1, col2, col3 = st.columns(3)
        col1.metric("本次 AA 总额", f"{total:.2f} 元")
        col2.metric("我垫付", f"{me_paid:.2f} 元")
        col3.metric("老婆垫付", f"{wife_paid:.2f} 元")

        if net > 0:
            st.info(f"老婆需转账给**我**：**{net:.2f}** 元")
        elif net < 0:
            st.info(f"我需要转账给**老婆**：**{abs(net):.2f}** 元")
        else:
            st.info("双方持平，无需转账")

        note = st.text_input("结清备注（可选）", placeholder="如：2024年1-3月生活费")

        if st.button("确认结清", type="primary"):
            ids = [e["id"] for e in unsettled]
            sid = db.create_settlement(ids, note)
            show_settlement_result(sid)
            st.rerun()

    # Past settlements
    settlements = db.get_settlements()
    if settlements:
        st.divider()
        st.subheader("历史结清记录")
        for s in settlements:
            with st.expander(f"{s['settlement_date']} — 总额 {s['total_amount']:.2f} 元 | 净转账 {s['net_transfer']:.2f} 元"):
                st.caption(s.get("note") or "无备注")
                for e in db.get_settlement_expenses(s["id"]):
                    st.write(f"- {e['expense_date']} {e['category']} {e['amount']:.2f} 元（{e['payer']}）")
