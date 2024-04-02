function fun_saving_F_newly_born(x)
    # Savings of entrepreneurs
    
    # Global variables
    global bet::Float64
    global r::Float64
    global sig::Float64
    global alp::Float64
    global ksi::Float64
    global psi::Float64
    global del::Float64
    global age_max::Int64
    global age_T_w::Int64
    global time_max::Int64
    global n_pre::Int64
    global e_pre::Int64
    global w_t::Vector{Float64}
    global m_t::Vector{Float64}
    global rho_t::Vector{Float64}
    global g_t::Float64
    
    # Other definition
    tt = x[1]  # year of birth
    
    # Agents born without assets
    wealth = zeros(age_max)
    wealth[1] = 0
    
    # Generating interest rate adjusted life-cycle earnings and others
    w = zeros(age_max)
    for i in 1:age_max
        if i < age_T_w
            w[i] = w_t[tt+i-1] * ((1 + g_t) / (1 + r))^(i-1)  # Earnings
        else
            w[i] = 0
        end
    end
    
    # Computing lifetime wealth
    A = sum(w)
    
    # Computing current optimal consumption and savings
    ratio = zeros(age_max)
    for i in 1:age_max
        # The interest rate adjusted ratio of optimal consumption to consumption of the current age
        if i == 1
            ratio[i] = 1
        else
            ratio[i] = (bet * (1 + r) / (1 + g_t))^(1 / sig) * (1 + g_t) / (1 + r) * ratio[i - 1]
        end
    end
    
    # Optimal consumption and savings
    consumption = zeros(age_max)
    for i in 1:age_max
        if i == 1
            consumption[i] = A / sum(ratio)
            wealth[2] = (w_t[tt] - consumption[i]) / (1 + g_t)
        elseif i < age_T_w  # Being workers
            consumption[i] = (bet * (1 + r) / (1 + g_t))^(1 / sig) * consumption[i - 1]
            wealth[i + 1] = (wealth[i] * (1 + r) + w_t[tt+i-1] - consumption[i]) / (1 + g_t)
        else  # Become retirees
            consumption[i] = (bet * (1 + r) / (1 + g_t))^(1 / sig) * consumption[i - 1]
            wealth[i + 1] = (wealth[i] * (1 + r) - consumption[i]) / (1 + g_t)
        end
    end
    
    # Definition of y
    y = [wealth'; consumption']
    
    return y
end