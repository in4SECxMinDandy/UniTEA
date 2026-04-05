'use client'

import { useState, useEffect } from 'react'
import { createClient } from '@/lib/supabase/client'
import { formatTime, formatPrice } from '@/lib/utils'
import { ShoppingBag, Loader2, Clock, Search, ArrowRight, UtensilsCrossed } from 'lucide-react'
import Link from 'next/link'
import { useRouter } from 'next/navigation'

type OrderFood = {
  name: string
  price: number
  image_url: string | null
}

type Order = {
  id: string
  food_id: string
  quantity: number
  note: string | null
  status: 'pending' | 'confirmed' | 'completed' | 'cancelled'
  total_price: number
  created_at: string
  food?: OrderFood | null
}

export default function OrderHistoryPage() {
  const [orders, setOrders] = useState<Order[]>([])
  const [loading, setLoading] = useState(true)
  const router = useRouter()
  const supabase = createClient()

  useEffect(() => {
    async function loadData() {
      const { data: { session } } = await supabase.auth.getSession()
      if (!session) {
        router.push('/login?redirect=history')
        return
      }
      
      fetchOrders()

      const channel = supabase.channel('user-orders-history')
        .on('postgres_changes', 
          { event: '*', schema: 'public', table: 'orders', filter: `user_id=eq.${session.user.id}` }, 
          () => { fetchOrders() }
        )
        .subscribe()

      return () => { supabase.removeChannel(channel) }
    }
    
    loadData()
  }, [router, supabase])

  async function fetchOrders() {
    setLoading(true)
    const { data } = await supabase
      .from('orders')
      .select(`
        *,
        food:foods(name, price, image_url)
      `)
      .order('created_at', { ascending: false })

    if (data) {
      setOrders(data as unknown as Order[])
    }
    setLoading(false)
  }

  const getStatusBadge = (status: Order['status']) => {
    switch (status) {
      case 'pending': return <span className="badge bg-yellow-100 text-yellow-700 border-yellow-200">Đang chờ xác nhận</span>
      case 'confirmed': return <span className="badge bg-blue-100 text-blue-700 border-blue-200">Đang chuẩn bị món</span>
      case 'completed': return <span className="badge bg-green-100 text-green-700 border-green-200">Hoàn thành</span>
      case 'cancelled': return <span className="badge bg-red-100 text-red-700 border-red-200">Đã hủy</span>
      default: return null
    }
  }

  if (loading && orders.length === 0) {
    return (
      <div className="min-h-[50vh] flex items-center justify-center">
        <Loader2 size={32} className="animate-spin text-primary opacity-50" />
      </div>
    )
  }

  return (
    <div className="page-container py-12 sm:py-16 animate-fade-in">
      <div className="mb-10">
        <div className="inline-flex items-center gap-1.5 text-xs font-medium text-text-secondary uppercase tracking-wider mb-3">
          <ShoppingBag size={12} />
          <span>Lịch sử</span>
        </div>
        <h1 className="section-heading">Đơn hàng của bạn</h1>
        <p className="section-subheading">
          Theo dõi trạng thái và lịch sử các món ăn bạn đã đặt
        </p>
      </div>

      <div className="flex flex-col gap-5">
        {orders.length === 0 ? (
          <div className="text-center py-20 bg-surface-card rounded-2xl border border-border-subtle shadow-sm flex flex-col items-center">
            <div className="w-16 h-16 rounded-full bg-gray-100 flex items-center justify-center mb-4">
              <Search size={24} className="text-text-muted" />
            </div>
            <h3 className="text-lg font-bold text-primary">Chưa có đơn hàng nào</h3>
            <p className="text-text-muted mt-1 mb-6">Bạn chưa đặt món ăn nào tại UniTEA.</p>
            <Link href="/thuc-pham" className="btn-primary">
              <UtensilsCrossed size={16} className="mr-2" />
              Khám phá thực đơn
            </Link>
          </div>
        ) : (
          orders.map(order => (
            <div key={order.id} className="card-base p-5 sm:p-6 flex flex-col md:flex-row gap-5 items-start md:items-center relative overflow-hidden transition-shadow duration-200 hover:shadow-card-hover group">
              {/* Image abstract if no image */}
              <div className="hidden sm:flex flex-shrink-0 w-20 h-20 rounded-xl bg-gray-100 items-center justify-center overflow-hidden">
                {order.food?.image_url ? (
                  <img src={order.food.image_url} alt={order.food.name} className="w-full h-full object-cover" />
                ) : (
                  <UtensilsCrossed size={28} className="text-gray-300" />
                )}
              </div>

              {/* Info section */}
              <div className="flex-1 space-y-2">
                <div className="flex items-center gap-2 mb-2">
                  <span className="text-xs font-medium text-text-muted bg-gray-100 px-2 py-1 rounded">
                    #{order.id.split('-')[0].toUpperCase()}
                  </span>
                  <span className="text-sm text-text-muted flex items-center gap-1">
                    <Clock size={14} />
                    {formatTime(order.created_at)}
                  </span>
                </div>
                
                <div>
                  <h3 className="text-xl font-bold text-primary">
                    {order.quantity}x {order.food?.name || 'Món ăn đã bị xóa'}
                  </h3>
                  <div className="text-sm text-text-secondary mt-1">
                     Tổng tiền: <span className="font-bold text-primary text-base ml-1">{formatPrice(order.total_price)}</span>
                  </div>
                </div>

                {order.note && (
                  <div className="text-sm text-text-muted italic mt-2">
                    <span className="not-italic text-text-secondary font-medium mr-1 border-b border-border-subtle border-dashed">Ghi chú:</span> 
                    {order.note}
                  </div>
                )}
              </div>

              {/* Status Section */}
              <div className="w-full md:w-auto flex justify-between md:flex-col items-center md:items-end gap-3 p-4 md:p-0 bg-gray-50 md:bg-transparent rounded-xl md:rounded-none border md:border-none border-border-subtle border-dashed">
                {getStatusBadge(order.status)}
                
                {order.status === 'pending' && (
                  <p className="text-xs text-text-muted text-right max-w-[150px]">
                    Đơn hàng sẽ sớm được nhân viên xác nhận.
                  </p>
                )}
                {order.status === 'confirmed' && (
                  <p className="text-xs text-accent-green text-right font-medium max-w-[150px] flex items-center gap-1 justify-end">
                    <Loader2 size={12} className="animate-spin" /> Đang chuẩn bị...
                  </p>
                )}
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  )
}
