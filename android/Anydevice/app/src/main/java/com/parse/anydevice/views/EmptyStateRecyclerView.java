package com.parse.anydevice.views;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.v7.widget.RecyclerView;
import android.util.AttributeSet;
import android.view.View;

/**
 * RecyclerView with with logic for empty state
 */
public class EmptyStateRecyclerView extends RecyclerView {

    private View emptyView;
    private final AdapterDataObserver observer = new EmptyDataObserver();

    public EmptyStateRecyclerView(final Context context) {
        super(context);
    }

    public EmptyStateRecyclerView(final Context context, final AttributeSet attrs) {
        super(context, attrs);
    }

    public EmptyStateRecyclerView(final Context context, final AttributeSet attrs, final int defStyle) {
        super(context, attrs, defStyle);
    }

    @Override
    public void setAdapter(final Adapter adapter) {
        final Adapter oldAdapter = getAdapter();
        if (oldAdapter != null) {
            oldAdapter.unregisterAdapterDataObserver(observer);
        }
        super.setAdapter(adapter);
        if (adapter != null) {
            adapter.registerAdapterDataObserver(observer);
        }
        setVisibility();
    }

    /**
     * Set visibility of views based on whether there are 0 or more items in the adapter
     */
    private void setVisibility() {
        if (emptyView != null && getAdapter() != null) {
            final boolean listIsEmpty = getAdapter().getItemCount() == 0;
            emptyView.setVisibility(listIsEmpty ? VISIBLE : INVISIBLE);
            setVisibility(listIsEmpty ? INVISIBLE : VISIBLE);
        }
    }

    /**
     * Set empty view for list view
     *
     * @param emptyView View that will be visible when the list is empty and invisible otherwise
     */
    public void setEmptyView(@NonNull final View emptyView) {
        this.emptyView = emptyView;
        setVisibility();
    }

    private class EmptyDataObserver extends AdapterDataObserver {
        @Override
        public void onChanged() {
            setVisibility();
        }

        @Override
        public void onItemRangeInserted(int positionStart, int itemCount) {
            setVisibility();
        }

        @Override
        public void onItemRangeRemoved(int positionStart, int itemCount) {
            setVisibility();
        }
    }
}
