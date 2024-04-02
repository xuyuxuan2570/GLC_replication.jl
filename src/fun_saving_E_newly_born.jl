function fun_saving_E_newly_born(x)
    # Savings of entrepreneurs

    global bet_E::Float64
    global r::Float64
    global sig::Float64
    global alp::Float64
    global ksi::Float64
    global psi::Float64
    global del::Float64
    global age_max::Int64
    global age_T::Int64
    global time_max::Int64
    global n_pre::Int64
    global e_pre::Int64
    global m_t::Vector{Float64}
    global rho_t::Vector{Float64}
    global g_t::Float64
    global eta::Float64
    global ice_t::Vector{Float64}

    # Adjusting rate of return due to the endogenous borrowing constraint
    rho_t_ad = max.(rho_t, (rho_t .* (1 .+ r ./ (1 .- ice_t)) .+ eta .* (rho_t .- r ./ (1 .- ice_t))) ./ (1 .+ r ./ (1 .- ice_t) .- eta .* (rho_t .- r ./ (1 .- ice_t))))

    # Other definitions
    tt = x[1]  # Year of birth

    # Agents born without assets
    wealth = zeros(age_max)

    # Generating interest rate adjusted life-cycle earnings and others
    w = zeros(age_max)
    for i = 1:age_max
        if i < age_T
            w[i] = m_t[tt+i-1] * ((1 + g_t) / (1 + r))^(i-1)  # Earnings
        else
            w[i] = 0
        end
    end

    # Computing lifetime wealth
    A = sum(w)

    # Computing current optimal consumption and savings
    ratio = zeros(age_max)
    for i = 1:age_max
        # The interest rate adjusted ratio of optimal consumption to consumption of the current age
        if i == 1
            ratio[i] = 1
        elseif i < age_T  # Being manager
            ratio[i] = (bet_E * (1 + r) / (1 + g_t))^(1 / sig) * (1 + g_t) / (1 + r) * ratio[i-1]
        else  # Become firm owner
            ratio[i] = (bet_E * (1 + rho_t_ad[tt+i-1]) / (1 + g_t))^(1 / sig) * (1 + g_t) / (1 + rho_t_ad[tt+i-1]) * ratio[i-1]
        end
    end

    # Optimal consumption and savings
    consumption = zeros(age_max)
    for i = 1:age_max
        if i == 1
            consumption[i] = A / sum(ratio)
            wealth[2] = (m_t[tt] - consumption[i]) / (1 + g_t)
        elseif i < age_T  # Being manager
            consumption[i] = (bet_E * (1 + r) / (1 + g_t))^(1 / sig) * consumption[i-1]
            wealth[i+1] = (wealth[i] * (1 + r) + m_t[tt+i-1] - consumption[i]) / (1 + g_t)
        else  # Become firm owner
            consumption[i] = (bet_E * (1 + rho_t_ad[tt+i-1]) / (1 + g_t))^(1 / sig) * consumption[i-1]
            wealth[i+1] = (wealth[i] * (1 + rho_t_ad[tt+i-1]) - consumption[i]) / (1 + g_t)
        end
    end

    # Definition of y
    y = [wealth'; consumption']

    return y
end